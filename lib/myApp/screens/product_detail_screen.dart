// Rich product-detail page (PDP): gallery, rating, features, pricing,
// rent/buy selector, assurances and the overview/specs/box/reviews tabs.
// Design from proto/overlays.jsx; data from the real ProductModel API.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pwt_website/myApp/widgets/chrome.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/cart_state.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../widgets/form_field.dart';
import '../widgets/layout.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import 'business_screens.dart';
import 'cart_screen.dart';
import '../../Backend/Products/show_product.dart';
import '../../Models/Products/products_model.dart';
import '../../Models/Products/product_image_model.dart';
import '../../Models/Products/product_price_model.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.size = 14});
  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final full = value.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int n = 1; n <= 5; n++)
          Icon(PwtIcons.star, size: size, color: n <= full ? const Color(0xFFF5A623) : PwtColors.hairline2),
      ],
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product, required this.role});
  final ProductModel product;
  final AccountKind role;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel _product = widget.product;
  bool _loading = false;
  int _heroIdx = 0;
  String _tab = 'overview';
  Plan _plan = Plan.rent;
  // Guest preview toggle: 0 = Individual (buy/rent), 1 = Company (request quote).
  // Only shown/used when signed out — a logged-in user's actual role decides this.
  int _guestView = 0;

  @override
  void initState() {
    super.initState();
    _plan = _defaultPlan(_product);
    if (widget.product.id != null) _fetchDetails(widget.product.id!);
  }

  // Pick the right default plan based on what prices the product actually has.
  // - quote-only → Plan.quote
  // - has rent price → Plan.rent (rent is preferred default)
  // - only buy price → Plan.buy
  Plan _defaultPlan(ProductModel p) {
    if (p.isQuoteOnly ?? false) return Plan.quote;
    final hasRent = p.prices.any((pr) => pr.term == 'rent');
    return hasRent ? Plan.rent : Plan.buy;
  }

  Future<void> _fetchDetails(int id) async {
    setState(() => _loading = true);
    final res = await getProductDetails(id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _product = res.data!;
        _heroIdx = 0;
        _loading = false;
        _plan = _defaultPlan(_product);
      });
    } else {
      setState(() => _loading = false);
    }
  }

  ProductPriceModel? get _rentPrice =>
      _product.prices.where((p) => p.term == 'rent').firstOrNull;
  ProductPriceModel? get _buyPrice =>
      _product.prices.where((p) => p.term == 'buy').firstOrNull;

  double? get _oldPriceAmt =>
      _product.originalPrice != null ? double.tryParse(_product.originalPrice!) : null;
  bool get _isDiscounted =>
      _oldPriceAmt != null && _buyPrice != null && double.tryParse(_buyPrice!.amount) != null;
  double? get _discountPct => double.tryParse(_product.discountPercentage ?? '') ??
      (_product.discount != null ? _product.discount!.toDouble() : null);

  bool get _isGuest => web.AppState.instance.user == null;

  // Effective role/view being previewed — a guest's toggle selection, or a
  // signed-in user's real account type. Drives which pane is shown (company
  // users always see the quote panel, matching myWeb2's product page).
  bool get _isBusinessView {
    if (_isGuest) return _guestView == 1;
    return widget.role == AccountKind.business;
  }

  bool get _isQuote => _isBusinessView || (_product.isQuoteOnly ?? false);

  Plan get _currentPlan {
    if (_isQuote) return Plan.quote;
    // If only buy price exists, always use buy regardless of _plan state.
    if (_rentPrice == null && _buyPrice != null) return Plan.buy;
    // If only rent price exists, always use rent.
    if (_buyPrice == null && _rentPrice != null) return Plan.rent;
    // Both exist: use whatever the user selected.
    if (_plan == Plan.buy && _buyPrice != null) return Plan.buy;
    return Plan.rent;
  }

  double get _rating => double.tryParse(_product.rentStars ?? '') ?? 4.7;

  List<ProductImageModel> get _images {
    if (_product.images.isNotEmpty) return _product.images;
    if (_product.primaryImageUrl != null) {
      return [ProductImageModel(url: _product.primaryImageUrl)];
    }
    return [];
  }

  String _fmtAmt(String amount) {
    final v = double.tryParse(amount);
    if (v == null) return amount;
    return v.truncate().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final ar = app.isArabic;

    final name = p.localizedName ?? p.name ?? p.code ?? '';
    final catName = p.category?.name ?? '';
    final blurb = p.shortDescription ?? '';
    final isQuoteOnly = p.isQuoteOnly ?? false;
    final images = _images;

    final features = p.benefits.isNotEmpty
        ? p.benefits
        : (ar
            ? ['مياه ساخنة وباردة ودرجة الحرارة العادية', 'موفر للطاقة', 'قفل أمان للأطفال', 'تصميم عصري أنيق']
            : ['Instant hot & cold', 'Energy efficient', 'Child safety lock', 'Sleek modern design']);

    final tabs = [
      (k: 'overview', label: s['overview']!),
      (k: 'specs', label: s['specifications']!),
    ];

    return DetailScaffold(
      title: name,
      floatingActionButton: widget.role == AccountKind.individual
          ? FloatingCart(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen(role: AccountKind.individual))))
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // gallery
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              children: [
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: PwtColors.surface,
                    border: Border.all(color: PwtColors.hairline),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_loading)
                        const CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)
                      else
                        ProductImage(
                          img: '',
                          imageUrl: images.isNotEmpty ? images[_heroIdx].url : null,
                          size: 232,
                        ),
                      if (p.tagLabel != null)
                        Positioned(
                          top: 12, left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: PwtColors.brand, borderRadius: BorderRadius.circular(999)),
                            child: Text(p.tagLabel!, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      if ((p.discount ?? 0) > 0)
                        Positioned(
                          top: 12, right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: PwtColors.success, borderRadius: BorderRadius.circular(999)),
                            child: Text('${p.discount}% OFF', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
                if (images.length > 1) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < images.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _heroIdx = i),
                              child: Container(
                                width: 60, height: 60,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: PwtColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: i == _heroIdx ? PwtColors.brand : PwtColors.hairline, width: 1.5),
                                ),
                                child: images[i].url != null
                                    ? Image.network(images[i].url!, fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 20, color: PwtColors.brandBorder))
                                    : const Icon(PwtIcons.drop, size: 20, color: PwtColors.brandBorder),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isBusinessView) ...[
                  if (catName.isNotEmpty) Eyebrow(catName),
                  const SizedBox(height: 4),
                  Text(name, style: PwtType.headline().copyWith(fontSize: 26)),
                  if (blurb.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(blurb, style: PwtType.body(color: PwtColors.textSec).copyWith(height: 1.5)),
                  ],
                  if ((p.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(p.description!, style: PwtType.body(color: PwtColors.textSec).copyWith(height: 1.5)),
                  ],
                  const SizedBox(height: 16),
                  // feature chips
                  if (features.isNotEmpty)
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 58,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: features.take(4).length,
                      itemBuilder: (context, i) {
                        final f = features[i];
                        return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: PwtColors.surface,
                              border: Border.all(color: PwtColors.hairline),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(PwtIcons.check, size: 15, color: PwtColors.brand),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(f, style: PwtType.caption(color: PwtColors.textPri).copyWith(fontSize: 12, fontWeight: FontWeight.w500))),
                              ],
                            ),
                          );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
                if (_isGuest) ...[
                  ModeTabs(
                    mode: _guestView == 0 ? AccountKind.individual : AccountKind.business,
                    onChanged: (k) => setState(() => _guestView = k == AccountKind.individual ? 0 : 1),
                    individualLabel: s['individualBuyRent']!,
                    businessLabel: s['companyRequestQuote']!,
                  ),
                  const SizedBox(height: 16),
                ],
                // price card / quote banner (company view always sees the
                // quote panel, matching myWeb2's business product page)
                if (_isBusinessView)
                  _companyPreview(context, s, ar)
                else if (!isQuoteOnly && (_rentPrice != null || _buyPrice != null))
                  PwtCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_rentPrice != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Eyebrow(s['rent']!),
                                    const SizedBox(height: 6),
                                    Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                                      const Dirham(size: 14),
                                      const SizedBox(width: 4),
                                      Text(_fmtAmt(_rentPrice!.amount), style: PwtType.title().copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                                      Text(s['perMonth']!, style: PwtType.caption()),
                                    ]),
                                  ],
                                ),
                              ),
                            if (_buyPrice != null)
                              Container(
                                padding: const EdgeInsets.only(left: 16),
                                decoration: const BoxDecoration(border: Border(left: BorderSide(color: PwtColors.hairline))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Eyebrow(s['buy']!),
                                    const SizedBox(height: 6),
                                    Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                                      Dirham(size: 14, color: _isDiscounted ? PwtColors.success : null),
                                      const SizedBox(width: 4),
                                      Text(_fmtAmt(_buyPrice!.amount), style: PwtType.title().copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: _isDiscounted ? PwtColors.success : PwtColors.textPri)),
                                    ]),
                                    if (_isDiscounted) ...[
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        Text(
                                          '${_buyPrice!.currency} ${_fmtAmt(_oldPriceAmt!.toStringAsFixed(0))}',
                                          style: PwtType.caption().copyWith(decoration: TextDecoration.lineThrough),
                                        ),
                                        if (_discountPct != null && _discountPct! > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: PwtColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                                            child: Text(
                                              '${_discountPct! % 1 == 0 ? _discountPct!.toInt() : _discountPct}% OFF',
                                              style: PwtType.caption().copyWith(color: PwtColors.success, fontWeight: FontWeight.w700, fontSize: 10.5),
                                            ),
                                          ),
                                        ],
                                      ]),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (_isDiscounted) ...[
                          const SizedBox(height: 10),
                          Text(ar ? 'عرض لفترة محدودة' : 'Limited-time offer', style: PwtType.caption().copyWith(color: PwtColors.success, fontSize: 11.5)),
                        ] else if (_rentPrice != null && _buyPrice != null) ...[
                          const SizedBox(height: 10),
                          Text(s['youSaveLine']!, style: PwtType.caption().copyWith(fontSize: 11.5)),
                        ],
                      ],
                    ),
                  )
                else if (isQuoteOnly)
                  PwtBanner(
                    variant: BannerVariant.info,
                    title: s['quoteOnly']!,
                    body: ar
                        ? 'يحدد السعر بناءً على متطلبات التركيب — فريقنا سيقترح حلاً مخصصاً.'
                        : 'Pricing is determined by your installation requirements — our team will tailor a quote for you.',
                  ),
                // rent/buy selector (individual only, when both prices exist)
                if (widget.role == AccountKind.individual && !_isQuote && _rentPrice != null && _buyPrice != null) ...[
                  const SizedBox(height: 16),
                  Eyebrow(s['rentOrBuy']!),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: PwtColors.hairline)),
                    child: Row(
                      children: [
                        _planTab(s['rent']!, '${_fmtAmt(_rentPrice!.amount)}${s['perMonth']}', _plan == Plan.rent, () => setState(() => _plan = Plan.rent)),
                        _planTab(s['buy']!, _fmtAmt(_buyPrice!.amount), _plan == Plan.buy, () => setState(() => _plan = Plan.buy)),
                      ],
                    ),
                  ),
                ],
                if (!_isBusinessView) ...[
                  const SizedBox(height: 16),
                  // assurances
                  Row(
                    children: [
                      _assurance(PwtIcons.truck, s['freeDelivery']!, s['freeDeliverySub']!),
                      const SizedBox(width: 8),
                      _assurance(PwtIcons.wrench, s['freeInstall']!, s['freeInstallSub']!),
                      const SizedBox(width: 8),
                      _assurance(PwtIcons.shield, s['warrantyTitle']!, s['warrantySub']!),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          // tabs
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PwtColors.hairline))),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final tb in tabs)
                    GestureDetector(
                      onTap: () => setState(() => _tab = tb.k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tb.k == _tab ? PwtColors.brand : Colors.transparent, width: 2))),
                        child: Text(tb.label, style: TextStyle(fontSize: 13.5, fontWeight: tb.k == _tab ? FontWeight.w700 : FontWeight.w500, color: tb.k == _tab ? PwtColors.brand : PwtColors.textSec)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _tabContent(features, s, ar),
          ),
        ],
      ),
      bottomBar: _buildBottomBar(s),
    );
  }

  void _addAndGo(BuildContext context, Plan plan) {
    // Requesting a quotation never requires an account first — matches
    // myWeb2's company pane, which pushes /rfq directly with no login gate.
    if (_isQuote) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RequestRfqScreen(preselectedProduct: _product)),
      );
      return;
    }
    if (_isGuest) {
      // This screen is pushed on top of the shell, so the app-level route
      // switch to Login happens *underneath* it — pop back to the root
      // route first, otherwise Login is invisible behind this pushed page.
      context.read<AppState>().goToLoginForProduct(_product);
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    final pid = _product.id?.toString() ?? _product.uuid ?? '';
    context.read<CartState>().addItem(pid, plan: plan);
  }

  Widget _buildBottomBar(Map<String, String> s) {
    if (_isQuote) {
      return Builder(builder: (ctx) => PwtButton(
        label: s['requestQuote']!,
        full: true,
        icon: PwtIcons.cart,
        onPressed: () => _addAndGo(ctx, _currentPlan),
      ));
    }
    final pid = _product.id?.toString() ?? _product.uuid ?? '';
    final plan = _currentPlan;
    return Consumer<CartState>(
      builder: (context, cart, _) {
        final item = cart.items.where((i) => i.productId == pid && i.plan == plan).firstOrNull;
        if (item == null) {
          return PwtButton(
            label: s['addToCart']!,
            full: true,
            icon: PwtIcons.cart,
            onPressed: () => _addAndGo(context, plan),
          );
        }
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: PwtColors.brandTint,
                  borderRadius: BorderRadius.circular(PwtRadius.button),
                  border: Border.all(color: PwtColors.brandBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _qtyButton(PwtIcons.minus, () => cart.setQty(pid, plan, item.qty - 1)),
                    Text('${item.qty}', style: PwtType.title().copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                    _qtyButton(PwtIcons.plus, () => cart.setQty(pid, plan, item.qty + 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => cart.removeItem(pid, plan),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PwtColors.surface,
                  borderRadius: BorderRadius.circular(PwtRadius.button),
                  border: Border.all(color: PwtColors.error),
                ),
                child: const Icon(PwtIcons.trash, color: PwtColors.error, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: PwtColors.brand),
      ),
    );
  }

  Widget _tabContent(List<String> features, Map<String, String> s, bool ar) {
    switch (_tab) {
      case 'specs':
        if (_product.specs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              ar ? 'لا توجد مواصفات متاحة.' : 'No specifications available.',
              style: PwtType.body(color: PwtColors.textSec),
            ),
          );
        }
        return PwtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < _product.specs.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(border: i == _product.specs.length - 1 ? null : const Border(bottom: BorderSide(color: PwtColors.hairline))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_product.specs[i].label ?? '', style: PwtType.label(color: PwtColors.textSec).copyWith(fontSize: 13)),
                      Flexible(child: Text(_product.specs[i].value ?? '', textAlign: TextAlign.end, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13))),
                    ],
                  ),
                ),
            ],
          ),
        );
      default: // overview
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final f in features)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(PwtIcons.check, size: 16, color: PwtColors.success),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f, style: PwtType.label().copyWith(fontSize: 13.5))),
                  ],
                ),
              ),
          ],
        );
    }
  }

  Widget _companyPreview(BuildContext context, Map<String, String> s, bool ar) {
    final points = ar
        ? const ['تسعير مخصص', 'خصومات على الطلبات بالجملة', 'مدير حساب مخصص', 'دعم ما بعد البيع']
        : const ['Personalised pricing', 'Bulk order discounts', 'Dedicated account manager', 'Dedicated after-sales support'];
    return PwtCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ar ? 'مهتم بهذا المنتج لعملك؟' : 'Interested in this product for your business?',
            style: PwtType.title().copyWith(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            ar ? 'احصل على عرض سعر مخصص يناسب احتياجاتك.' : 'Get a customized quotation tailored to your needs.',
            style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(PwtIcons.check, size: 16, color: PwtColors.brand),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p, style: PwtType.body().copyWith(fontSize: 13))),
                ],
              ),
            ),
          // const SizedBox(height: 4),
          // PwtButton(
          //   label: s['requestQuotation']!,
          //   full: true,
          //   icon: PwtIcons.message,
          //   onPressed: () => _addAndGo(context, Plan.quote),
          // ),
          // const SizedBox(height: 10),
          // Row(
          //   children: [
          //     const Icon(PwtIcons.info, size: 14, color: PwtColors.textTer),
          //     const SizedBox(width: 8),
          //     Expanded(
          //       child: Text(
          //         ar ? 'سيتواصل معك فريقنا خلال 24 ساعة.' : 'Our team will get back to you within 24 hours.',
          //         style: PwtType.caption(color: PwtColors.textSec),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _planTab(String label, String sub, bool on, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: PwtMotion.fast,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: on ? PwtColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: on ? const [BoxShadow(color: Color(0x1F0F172A), blurRadius: 4, offset: Offset(0, 1))] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(fontSize: 13.5, fontWeight: on ? FontWeight.w700 : FontWeight.w600, color: on ? PwtColors.textPri : PwtColors.textSec)),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Dirham(size: 9, color: PwtColors.textTer),
                  const SizedBox(width: 2),
                  Text(sub, style: PwtType.caption().copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assurance(IconData icon, String title, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 18, color: PwtColors.brand),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 11)),
            const SizedBox(height: 2),
            Text(sub, textAlign: TextAlign.center, style: PwtType.caption().copyWith(fontSize: 9.5)),
          ],
        ),
      ),
    );
  }
}
