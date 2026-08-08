import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../../Models/Products/products_model.dart';
import '../../Models/Products/product_price_model.dart';
import '../../Backend/Products/show_product.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductModel? _product;
  bool _loading = false;
  int _img = 0;
  int _view = 0; // 0 individual, 1 company
  int _mode = 0; // 0 buy, 1 rent
  int _tab = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProductModel) {
      setState(() => _product = args);
      if (args.id != null) _fetchDetails(args.id!);
    }
  }

  Future<void> _fetchDetails(int id) async {
    setState(() => _loading = true);
    final result = await getProductDetails(id);
    if (!mounted) return;
    if (result.success && result.data != null) {
      setState(() { _product = result.data; _img = 0; _loading = false; });
    } else {
      setState(() => _loading = false);
    }
  }

  ProductPriceModel? get _purchasePrice =>
      _product?.prices.where((p) => p.term == 'buy').firstOrNull;

  ProductPriceModel? get _rentalPrice =>
      _product?.prices.where((p) => p.term == 'rent').firstOrNull;

  String _fmtPrice(ProductPriceModel? price) {
    if (price == null) return '';
    final amt = double.tryParse(price.amount);
    if (amt == null) return '${price.currency} ${price.amount}';
    return '${price.currency} ${amt.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    final wide = MediaQuery.of(context).size.width > 900;
    // final name = p?.name ?? '';
    final code = p?.code ?? '';

    return StoreScaffold(active: '/shop', slivers: [
      SliverToBoxAdapter(
        child: Band(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // breadcrumb
          Row(children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
              child: Text('Home', style: AppText.muted.copyWith(color: AppColors.blue700)),
            ),
            Text('  ›  ', style: AppText.muted),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/shop'),
              child: Text('Shop', style: AppText.muted.copyWith(color: AppColors.blue700)),
            ),
            Text('  ›  $code', style: AppText.muted),
          ]),
          const SizedBox(height: 14),
          if (p == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            Builder(builder: (_) {
              final user = AppState.instance.user;
              final isQuoteOnly = p.isQuoteOnly == true;
              final int effectiveView;
              final bool showSegmented;
              final bool showLockedBusiness;
              if (isQuoteOnly) {
                // Quote-only products have no individual buy/rent option at
                // all, so there's nothing to switch between.
                effectiveView = 1;
                showSegmented = false;
                showLockedBusiness = user == null;
              } else if (user == null) {
                effectiveView = _view;
                showSegmented = true;
                showLockedBusiness = false;
              } else if (user.isCompany) {
                effectiveView = 1;
                showSegmented = false;
                showLockedBusiness = false;
              } else {
                effectiveView = 0;
                showSegmented = false;
                showLockedBusiness = false;
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (showSegmented) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Segmented(
                      options: const ['Individual — Buy / Rent', 'Company — Request Quote'],
                      index: _view,
                      onChanged: (i) => setState(() => _view = i),
                    ),
                  ),
                  const SizedBox(height: 22),
                ] else if (showLockedBusiness) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.apartment_outlined, size: 16, color: AppColors.blue700),
                        const SizedBox(width: 7),
                        Text('Company — Request Quote', style: AppText.label.copyWith(color: AppColors.ink900)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: wide ? 1 : 0, child: _gallerySection(p)),
                    SizedBox(width: wide ? 30 : 0, height: wide ? 0 : 24),
                    Expanded(flex: wide ? 1 : 0, child: effectiveView == 0 ? _individualPane(p) : _companyPane()),
                  ],
                ),
              ]);
            }),
            const SizedBox(height: 30),
            _detailTabs(p),
          ],
        ])),
      ),
    ]);
  }

  // ── Gallery ──────────────────────────────────────────────────

  Widget _gallerySection(ProductModel p) {
    final images = p.images;
    final hasImages = images.isNotEmpty;

    Widget mainImage() {
      if (!hasImages) return const Icon(Icons.water_drop_outlined, size: 72, color: AppColors.blue200);
      final url = images[_img].url;
      if (url == null) return const Icon(Icons.water_drop_outlined, size: 72, color: AppColors.blue200);
      return Image.network(url, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 72, color: AppColors.blue200));
    }

    return Column(children: [
      Container(
        height: 380,
        decoration: BoxDecoration(
          color: AppColors.soft,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.line),
        ),
        child: Stack(children: [
          if (p.tagLabel != null)
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(color: AppColors.blue700, borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text(p.tagLabel!, style: AppText.muted.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10.5)),
              ),
            ),
          Center(child: Padding(padding: const EdgeInsets.all(24), child: mainImage())),
        ]),
      ),
      if (hasImages && images.length > 1) ...[
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(images.length, (i) {
            final on = i == _img;
            final url = images[i].url;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _img = i),
                child: Container(
                  width: 64, height: 64,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: on ? AppColors.blue600 : AppColors.line, width: on ? 2 : 1),
                  ),
                  child: url != null
                      ? Image.network(url, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 20, color: AppColors.blue200))
                      : const Icon(Icons.water_drop_outlined, size: 20, color: AppColors.blue200),
                ),
              ),
            );
          })),
        ),
      ],
    ]);
  }

  // ── Individual pane ──────────────────────────────────────────

  Widget _individualPane(ProductModel p) {
    final isRent = _mode == 1;
    final buyPrice = _purchasePrice;
    final rentPrice = _rentalPrice;
    final oldPriceAmt = p.originalPrice != null ? double.tryParse(p.originalPrice!) : null;
    final buyAmt = buyPrice != null ? double.tryParse(buyPrice.amount) : null;
    final isDiscounted = oldPriceAmt != null && buyAmt != null;
    final currency = buyPrice?.currency ?? rentPrice?.currency ?? '';
    final discountPct = double.tryParse(p.discountPercentage ?? '');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.code ?? '', style: AppText.headline(30)),
      const SizedBox(height: 4),
      if ((p.shortDescription ?? '').isNotEmpty)
        Text(p.shortDescription!, style: AppText.bodyLg),
      const SizedBox(height: 14),
      if ((p.description ?? '').isNotEmpty) ...[
        Text(p.description!, style: AppText.body.copyWith(height: 1.6)),
        const SizedBox(height: 18),
      ],
      // benefits
      if (p.benefits.isNotEmpty) ...[
        Wrap(
          spacing: 12, runSpacing: 12,
          children: p.benefits.map((b) => SizedBox(
            width: 220,
            child: Row(children: [
              const Icon(Icons.check_circle_outline, size: 18, color: AppColors.blue600),
              const SizedBox(width: 8),
              Flexible(child: Text(b, style: AppText.body)),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 20),
      ],
      // price
      if (!isRent && buyPrice != null) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(_fmtPrice(buyPrice), style: AppText.headline(28).copyWith(color: isDiscounted ? AppColors.discount : AppColors.ink900)),
          if (isDiscounted) ...[
            const SizedBox(width: 10),
            Text('$currency ${oldPriceAmt!.toStringAsFixed(0)}', style: AppText.bodyLg.copyWith(decoration: TextDecoration.lineThrough)),
            const SizedBox(width: 10),
            if (discountPct != null && discountPct > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: AppColors.badgeGreenBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text('${discountPct % 1 == 0 ? discountPct.toInt() : discountPct}% OFF', style: AppText.muted.copyWith(color: AppColors.discount, fontWeight: FontWeight.w700)),
              ),
          ],
        ]),
        const SizedBox(height: 4),
        if (isDiscounted)
          Text('Limited-time offer', style: AppText.muted.copyWith(color: AppColors.discount)),
      ] else if (isRent && rentPrice != null) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(_fmtPrice(rentPrice), style: AppText.headline(28)),
          const SizedBox(width: 4),
          Text('/ ${rentPrice.period ?? 'month'}', style: AppText.bodyLg),
        ]),
        const SizedBox(height: 4),
        Text('Billed monthly · cancel anytime', style: AppText.muted.copyWith(color: AppColors.discount)),
      ] else if (p.isQuoteOnly == true) ...[
        Text('Price on request', style: AppText.headline(22).copyWith(color: AppColors.ink500)),
      ],
      const SizedBox(height: 16),
      // buy / rent toggle
      if (buyPrice != null || rentPrice != null)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm + 2), border: Border.all(color: AppColors.line)),
          child: Row(children: [
            if (buyPrice != null) _modeTab('Buy', 0),
            if (rentPrice != null) _modeTab('Rent', 1),
          ]),
        ),
      const SizedBox(height: 14),
      AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) {
          final mode = isRent ? 'rent' : 'buy';
          final line = AppState.instance.cart.where((l) => l.product.id == p.id && l.mode == mode).firstOrNull;
          if (line == null) {
            return PwtButton(
              isRent ? 'Start Rental' : 'Add to Cart',
              icon: Icons.shopping_cart_outlined,
              fullWidth: true,
              onPressed: () {
                if (AppState.instance.user == null) {
                  Navigator.of(context).pushNamed('/login', arguments: {'returnRoute': '/product', 'returnArguments': p});
                  return;
                }
                AppState.instance.addToCart(p, mode: mode);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${p.name ?? 'Product'} added to cart'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.ink900,
                  action: SnackBarAction(label: 'View Cart', textColor: Colors.white, onPressed: () => Navigator.of(context).pushNamed('/cart')),
                ));
              },
            );
          }
          return Row(children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 1),
                  border: Border.all(color: AppColors.blue200, width: 1.5),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _qtyStepBtn(Icons.remove, () => AppState.instance.decQty(line)),
                  Text('${line.qty}', style: AppText.label.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                  _qtyStepBtn(Icons.add, () => AppState.instance.incQty(line)),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => AppState.instance.removeLine(line),
              borderRadius: BorderRadius.circular(AppRadius.sm + 1),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 1),
                  border: Border.all(color: const Color(0xFFF3C9C9), width: 1.5),
                ),
                child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
              ),
            ),
          ]);
        },
      ),
      const SizedBox(height: 10),
      PwtButton(
        isRent ? 'See Rental Plans' : 'Buy Now',
        variant: PwtBtn.outline,
        fullWidth: true,
        onPressed: () {
          if (AppState.instance.user == null) {
            Navigator.of(context).pushNamed('/login', arguments: {'returnRoute': '/product', 'returnArguments': p});
            return;
          }
          AppState.instance.addToCart(p, mode: isRent ? 'rent' : 'buy');
          Navigator.of(context).pushNamed('/checkout', arguments: isRent ? 'rent' : 'buy');
        },
      ),
      const SizedBox(height: 18),
      Row(children: const [
        Expanded(child: _Assurance(Icons.local_shipping_outlined, 'Free Delivery', '3–5 business days')),
        Expanded(child: _Assurance(Icons.build_outlined, 'Free Installation', 'On all orders')),
        Expanded(child: _Assurance(Icons.shield_outlined, '2 Years Warranty', 'Peace of mind')),
      ]),
    ]);
  }

  Widget _qtyStepBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: AppColors.blue700),
        ),
      );

  Widget _modeTab(String label, int i) {
    final on = _mode == i;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _mode = i),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: on ? AppShadow.card : null,
        ),
        child: Text(label, style: AppText.label.copyWith(color: on ? AppColors.ink900 : AppColors.ink500)),
      ),
    ));
  }

  // ── Company pane ─────────────────────────────────────────────

  Widget _companyPane() {
    const checks = ['Personalised pricing', 'Bulk order discounts', 'Dedicated account manager', 'Dedicated after-sales support'];
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Interested in this product for your business?', style: AppText.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 8),
        Text('Get a customized quotation tailored to your needs.', style: AppText.bodyLg),
        const SizedBox(height: 16),
        ...checks.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [const Icon(Icons.check_circle_outline, size: 18, color: AppColors.blue600), const SizedBox(width: 10), Text(c, style: AppText.body)]),
        )),
        const SizedBox(height: 8),
        PwtButton('Request a Quotation', icon: Icons.description_outlined, fullWidth: true, onPressed: () => Navigator.of(context).pushNamed('/rfq', arguments: {'id': _product?.id, 'name': _product?.name, 'code': _product?.code})),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.ink400),
          const SizedBox(width: 8),
          Expanded(child: Text('Our team will get back to you within 24 hours.', style: AppText.muted)),
        ]),
      ]),
    );
  }

  // ── Detail tabs ──────────────────────────────────────────────

  Widget _detailTabs(ProductModel p) {
    final tabs = ['Overview', 'Specifications'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(tabs.length, (i) {
          final on = _tab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: on ? AppColors.blue700 : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: on ? AppColors.blue700 : AppColors.line),
                ),
                child: Text(tabs[i], style: AppText.label.copyWith(color: on ? Colors.white : AppColors.ink600)),
              ),
            ),
          );
        })),
      ),
      const SizedBox(height: 18),
      _tabBody(p),
    ]);
  }

  Widget _tabBody(ProductModel p) {
    switch (_tab) {
      case 1:
        return _specsTab(p);
      case 2:
        return _reviews();
      case 3:
        return _docs(p);
      default:
        return _overviewTab(p);
    }
  }

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
        child: child,
      );

  Widget _overviewTab(ProductModel p) {
    final items = p.benefits.isNotEmpty
        ? p.benefits
        : ['Hot, cold & ambient water', 'Touch panel with child safety lock', 'Energy saving & eco-friendly', 'Removable drip tray for easy cleaning'];
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Product highlights', style: AppText.h2.copyWith(fontSize: 19)),
      const SizedBox(height: 14),
      ...items.map((b) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check, size: 18, color: AppColors.blue600),
          const SizedBox(width: 10),
          Expanded(child: Text(b, style: AppText.body)),
        ]),
      )),
    ]));
  }

  Widget _specsTab(ProductModel p) {
    if (p.specs.isEmpty) {
      return _card(Text('No specifications available.', style: AppText.muted));
    }
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Technical specifications', style: AppText.h2.copyWith(fontSize: 19)),
      const SizedBox(height: 14),
      ...p.specs.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 160, child: Text(s.label ?? '', style: AppText.label)),
          const SizedBox(width: 12),
          Expanded(child: Text(s.value ?? '', style: AppText.body)),
        ]),
      )),
    ]));
  }

  Widget _reviews() {
    final revs = [
      ['SJ', 'Sarah J.', 'Verified buyer · 12 May 2026', 5, 'Genuinely tastes great. Installation took 15 minutes and the touch panel feels premium. Happy customer.'],
      ['MK', 'Michael K.', 'Verified buyer · 28 Apr 2026', 4, 'Solid build quality. Hot water is properly hot and cold is properly cold. Only wish the cold tank were a touch larger.'],
      ['AR', 'Aisha R.', 'Verified buyer · 03 Apr 2026', 5, "Beautiful design that doesn't look out of place in the kitchen. The kids love it (and the child-safety lock is appreciated)."],
    ];
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: revs.map((r) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: AppColors.blue100, child: Text(r[0] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.blue800))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r[1] as String, style: AppText.label),
            Text(r[2] as String, style: AppText.muted),
          ]),
          const Spacer(),
          Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < (r[3] as int) ? const Color(0xFFF5B400) : AppColors.line))),
        ]),
        const SizedBox(height: 8),
        Text(r[4] as String, style: AppText.body.copyWith(height: 1.5)),
      ]),
    )).toList()));
  }

  Widget _docs(ProductModel p) {
    final name = p.name ?? 'Product';
    final docs = [
      ['$name User Manual', 'PDF · 2.4 MB'],
      ['Installation Guide', 'PDF · 1.1 MB'],
      ['CE / Safety Certificate', 'PDF · 480 KB'],
      ['Warranty Information', 'PDF · 220 KB'],
    ];
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Manuals & certifications', style: AppText.h2.copyWith(fontSize: 19)),
      const SizedBox(height: 14),
      ...docs.map((d) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description_outlined, size: 20, color: AppColors.blue700)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d[0], style: AppText.label), Text(d[1], style: AppText.muted)])),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 14), label: const Text('Download')),
        ]),
      )),
    ]));
  }
}

// ── Assurance chip ────────────────────────────────────────────

class _Assurance extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _Assurance(this.icon, this.title, this.sub);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 20, color: AppColors.blue600),
      const SizedBox(height: 6),
      Text(title, style: AppText.muted.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink800), textAlign: TextAlign.center),
      Text(sub, style: AppText.muted.copyWith(fontSize: 11), textAlign: TextAlign.center),
    ]);
  }
}
