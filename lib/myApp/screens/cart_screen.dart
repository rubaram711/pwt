// Cart, checkout and success flows.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../../Backend/Products/show_product.dart';
import '../../Models/Products/products_model.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/cart_state.dart';
import '../widgets/layout.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Addresses/get_addresses.dart';
import '../../Backend/Users/PaymentCards/get_payment_cards.dart';
import '../../Backend/Orders/place_order.dart';
import '../../Backend/Payments/initiate_payment.dart';
import '../../Backend/Payments/get_payment_status.dart';
import '../../Models/Payments/payment_model.dart';
import '../../Models/address_model.dart';
import '../../Models/payment_card_model.dart';
import '../../Models/Orders/order_model.dart';
import 'account_screens.dart';

String _genOrderId(AccountKind role) {
  final n = 2300 + Random().nextInt(999);
  return role == AccountKind.business ? 'PWT-B-$n' : 'PWT-${1100 + Random().nextInt(99)}';
}

class _ApiRow {
  const _ApiRow({required this.item, required this.product});
  final CartItem item;
  final ProductModel product;

  int get qty => item.qty;
  Plan get plan => item.plan;
  bool get isQuoteOnly => product.isQuoteOnly ?? false;
  bool get isQuote => plan == Plan.quote || isQuoteOnly;

  double get rentPrice =>
      double.tryParse(product.prices.where((p) => p.term == 'rent').firstOrNull?.amount ?? '') ?? 0;
  double get buyPrice =>
      double.tryParse(product.prices.where((p) => p.term == 'buy').firstOrNull?.amount ?? '') ?? 0;
  double get unit => plan == Plan.buy ? buyPrice : rentPrice;
  double get lineTotal => isQuote ? 0 : unit * qty;
}

// ─── Cart ───
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.role});
  final AccountKind role;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Map<String, ProductModel> _products = {};
  final Set<String> _fetching = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMissing();
  }

  Future<void> _fetchMissing() async {
    final cart = context.read<CartState>();
    final ids = cart.items.map((i) => i.productId).toSet().difference(_fetching);
    print('[CartScreen._fetchMissing] cartItems=${cart.items.length} newIds=$ids alreadyFetching=$_fetching');
    if (ids.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    _fetching.addAll(ids);
    await Future.wait(ids.map((id) async {
      final intId = int.tryParse(id);
      if (intId == null) {
        print('[CartScreen._fetchMissing] ERROR: productId="$id" is not a valid int');
        return;
      }
      print('[CartScreen._fetchMissing] fetching getProductDetails($intId)...');
      final res = await getProductDetails(intId);
      print('[CartScreen._fetchMissing] id=$id success=${res.success} message=${res.message} name=${res.data?.localizedName ?? res.data?.name} localizedName=${res.data?.localizedName}');
      if (res.success && res.data != null && mounted) {
        setState(() => _products[id] = res.data!);
      }
    }));
    if (mounted) setState(() => _loading = false);
    print('[CartScreen._fetchMissing] done. cached products: ${_products.keys.toList()}');
  }

  List<_ApiRow> _rows(CartState cart) {
    final rows = cart.items
        .where((i) => _products.containsKey(i.productId))
        .map((i) => _ApiRow(item: i, product: _products[i.productId]!))
        .toList();
    final missing = cart.items.where((i) => !_products.containsKey(i.productId)).map((i) => i.productId).toList();
    if (missing.isNotEmpty) print('[CartScreen._rows] waiting for product details: $missing');
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);

    // If cart is empty (no backend items at all)
    if (!_loading && cart.isEmpty) {
      return DetailScaffold(
        title: s['yourCart'],
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Column(
            children: [
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(color: PwtColors.surface2, shape: BoxShape.circle, border: Border.all(color: PwtColors.hairline)),
                child: const Icon(PwtIcons.cart, size: 36, color: PwtColors.textTer),
              ),
              const SizedBox(height: 18),
              Text(s['emptyCart']!, style: PwtType.title().copyWith(fontSize: 20)),
              const SizedBox(height: 8),
              Text(s['emptyCartSub']!, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5)),
              const SizedBox(height: 24),
              PwtButton(label: s['browseProducts']!, onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return DetailScaffold(
        title: s['yourCart'],
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
      );
    }

    // Fetch details for any newly added items
    _fetchMissing();

    final rows = _rows(cart);
    final subtotal = rows.fold<double>(0, (sum, r) => sum + r.lineTotal);
    final hasQuote = rows.any((r) => r.isQuote);
    final vat = subtotal * 0.05;
    final total = subtotal + vat;
    final quoteFlow = widget.role == AccountKind.business || hasQuote;
    final isLoggedIn = web.AppState.instance.user != null;

    return DetailScaffold(
      title: s['yourCart'],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Text('${rows.length} ${rows.length == 1 ? s['item'] : s['items']}', style: PwtType.caption().copyWith(fontSize: 12)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.read<CartState>().clearBackend(),
                  child: Text('Clear cart', style: PwtType.caption().copyWith(fontSize: 12, color: PwtColors.error)),
                ),
              ],
            ),
          ),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CartItemCard(row: r),
            ),
          if (widget.role == AccountKind.individual && !hasQuote) ...[
            const SizedBox(height: 6),
            PwtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SummaryRow(label: s['subtotal']!, value: _money(subtotal, PwtColors.textSec)),
                  SummaryRow(label: s['shippingFee']!, value: Text(s['free']!, style: const TextStyle(color: PwtColors.success, fontWeight: FontWeight.w600))),
                  SummaryRow(label: s['vat']!, value: _money(vat, PwtColors.textSec)),
                  SummaryRow(label: s['total']!, bold: true, last: true, value: _money(total, PwtColors.textPri)),
                ],
              ),
            ),
          ],
          if (quoteFlow) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PwtColors.brandTint,
                border: Border.all(color: PwtColors.brandBorder),
                borderRadius: BorderRadius.circular(PwtRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(PwtIcons.info, size: 18, color: PwtColors.brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      app.isArabic
                          ? 'يتم تحديد الأسعار النهائية بناءً على متطلبات الشركة. سيتواصل معك فريقنا بعرض السعر خلال 24 ساعة.'
                          : 'Final pricing is determined based on your company\'s requirements. Our team will share a tailored quotation within 24 hours.',
                      style: PwtType.body(color: PwtColors.textPri).copyWith(fontSize: 12.5, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isLoggedIn) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PwtColors.brandTint,
                border: Border.all(color: PwtColors.brandBorder),
                borderRadius: BorderRadius.circular(PwtRadius.card),
              ),
              child: Row(
                children: [
                  const Icon(PwtIcons.info, size: 18, color: PwtColors.brand),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Sign in or register to proceed to checkout.', style: PwtType.body(color: PwtColors.brand).copyWith(fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomBar: quoteFlow
          ? PwtButton(
              label: s['requestQuotation']!,
              full: true,
              icon: PwtIcons.message,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuotationSuccessScreen(rows: rows, role: widget.role))),
            )
          : PwtButton(
              label: isLoggedIn ? s['proceedToCheckout']! : 'Sign in to Checkout',
              full: true,
              trailing: PwtIcons.arrow,
              onPressed: isLoggedIn
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(rows: rows, subtotal: subtotal, vat: vat, total: total)))
                  : () {
                      // CartScreen is pushed on top of the shell, so popping
                      // back to root is needed for the Login screen (swapped
                      // in underneath) to actually become visible.
                      context.read<AppState>().go(AppRoute.login);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
            ),
    );
  }
}

Widget _money(num v, Color color, {double symbol = 11, double size = 14, FontWeight weight = FontWeight.w600}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Dirham(size: symbol, color: color),
      const SizedBox(width: 3),
      Text(_fmt(v), style: TextStyle(color: color, fontSize: size, fontWeight: weight)),
    ],
  );
}

String _fmt(num v) {
  final s = v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.row});
  final _ApiRow row;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartState>();
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final p = row.product;

    return Container(
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(PwtRadius.card),
        boxShadow: PwtShadows.e1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76, height: 88,
                  decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: PwtColors.hairline)),
                  alignment: Alignment.center,
                  child: p.primaryImageUrl != null && p.primaryImageUrl!.isNotEmpty
                      ? Image.network(p.primaryImageUrl!, height: 70, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 30, color: PwtColors.brand))
                      : const Icon(PwtIcons.drop, size: 30, color: PwtColors.brand),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Eyebrow(p.category?.name ?? '', color: PwtColors.brand),
                                const SizedBox(height: 4),
                                Text(p.localizedName ?? p.name?.toString() ?? p.code ?? '', style: PwtType.subtitle().copyWith(fontSize: 15)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cart.removeItem(row.item.productId, row.plan),
                            child: const Icon(PwtIcons.close, size: 18, color: PwtColors.textTer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (row.isQuote)
                        Text(s['quoteOnly']!, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13))
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Dirham(size: 12),
                            const SizedBox(width: 4),
                            Text(_fmt(row.unit), style: PwtType.subtitle().copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                            if (row.plan == Plan.rent) Text(s['perMonth']!, style: PwtType.caption().copyWith(fontSize: 12)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: PwtColors.brandTint,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: PwtColors.brandBorder),
                              ),
                              child: Text(
                                row.plan == Plan.buy ? s['buy']! : s['rent']!,
                                style: PwtType.caption().copyWith(fontSize: 10.5, color: PwtColors.brand, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s['quantity']!, style: PwtType.caption(color: PwtColors.textSec).copyWith(fontSize: 12)),
                Row(
                  children: [
                    _StepBtn(icon: PwtIcons.minus, enabled: row.qty > 1, onTap: () => cart.setQty(row.item.productId, row.plan, row.qty - 1)),
                    Container(
                      constraints: const BoxConstraints(minWidth: 44),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${row.qty}', style: PwtType.mono(size: 15, weight: FontWeight.w600)),
                    ),
                    _StepBtn(icon: PwtIcons.plus, primary: true, onTap: () => cart.setQty(row.item.productId, row.plan, row.qty + 1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap, this.enabled = true, this.primary = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: primary ? PwtColors.brandTint : PwtColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primary ? PwtColors.brandBorder : PwtColors.hairline2),
          ),
          child: Icon(icon, size: 16, color: primary ? PwtColors.brand : PwtColors.textPri),
        ),
      ),
    );
  }
}

// ─── Checkout (multi-step) ───

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.rows, required this.subtotal, required this.vat, required this.total});
  final List<_ApiRow> rows;
  final double subtotal;
  final double vat;
  final double total;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0; // 0=information 1=delivery 2=payment

  // Step 0 – address
  List<AddressModel> _addresses = [];
  bool _loadingAddresses = true;
  AddressModel? _selectedAddress;
  String? _addressError;

  // Step 1 – delivery
  DateTime? _deliveryDate;
  String? _timeSlot; // 'morning' | 'afternoon' | 'evening'

  // Step 2 – payment
  String _paymentMethod = 'card';
  List<PaymentCard> _cards = [];
  bool _loadingCards = false;
  int? _selectedCardId;
  bool _enterNewCard = false;
  bool _cardComplete = false;
  bool _cardTouched = false;
  final _promoCtrl    = TextEditingController();
  final _notesCtrl    = TextEditingController();

  // Submission
  bool _submitting = false;
  bool _confirmingCard = false;
  String? _error;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final res = await getAddresses();
    if (!mounted) return;
    setState(() {
      _loadingAddresses = false;
      if (res.success && res.data != null) {
        _addresses = res.data!;
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
            (a) => a.isDefault == true,
            orElse: () => _addresses.first,
          );
        }
      } else {
        _addressError = res.message ?? 'Failed to load addresses.';
      }
    });
  }

  Future<void> _openProfileToAddAddress() async {
    final u = web.AppState.instance.user;
    final role = web.AppState.instance.isCompany ? AccountKind.business : AccountKind.individual;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen(
      user: AppUser(
        name: u?.name ?? '',
        initials: u?.initials ?? 'PW',
        phone: u?.phone ?? '',
        email: u?.email ?? '',
        kind: role,
        addressLabel: '',
      ),
      role: role,
    )));
    if (!mounted) return;
    setState(() { _loadingAddresses = true; _addressError = null; });
    _loadAddresses();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _loadingCards = true);
    final res = await getPaymentCards();
    if (!mounted) return;
    setState(() {
      _loadingCards = false;
      if (res.success && res.data != null) {
        _cards = res.data!;
        final def = _cards.where((c) => c.isDefault).firstOrNull;
        _selectedCardId = def?.id ?? (_cards.isNotEmpty ? _cards.first.id : null);
      }
    });
  }

  // A new card is entered inline on this step via Stripe's embedded
  // CardField whenever there are no saved cards, or the user opted to use a
  // different one.
  bool get _needsNewCard => _cards.isEmpty || _enterNewCard;

  bool get _canProceed {
    switch (_step) {
      case 0: return _selectedAddress != null;
      case 1: return _deliveryDate != null && _timeSlot != null;
      case 2:
        if (_paymentMethod == 'apple_pay' || _paymentMethod == 'google_pay') return true;
        if (_paymentMethod != 'card') return false;
        return _needsNewCard ? _cardComplete : _selectedCardId != null;
      default: return false;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  Future<void> _submit() async {
    final user = web.AppState.instance.user;
    final term = widget.rows.isNotEmpty ? widget.rows.first.plan.id : 'buy';

    setState(() { _submitting = true; _error = null; });

    final items = widget.rows.map((r) => {
      'product_id': int.tryParse(r.item.productId) ?? 0,
      'quantity': r.qty,
      'term': r.plan.id,
    }).toList();

    final dateStr = _deliveryDate != null
        ? '${_deliveryDate!.year}-${_deliveryDate!.month.toString().padLeft(2, '0')}-${_deliveryDate!.day.toString().padLeft(2, '0')}'
        : null;

    final promo = _promoCtrl.text.trim().isEmpty ? null : _promoCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    // A new card is captured entirely by Stripe's native PaymentSheet on the
    // processing screen next — its real digits never touch our backend.
    // /orders still requires card_number/card_expiry to be present for
    // payment_method=card, so we send inert placeholders here; the actual
    // charge is authorized purely via Stripe's client_secret + PaymentSheet,
    // never from these fields.
    final usingSavedCard = _paymentMethod == 'card' && !_needsNewCard && _selectedCardId != null;
    String? cardNumber;
    String? cardExpiry;
    String? cardCvc;
    if (_paymentMethod == 'card') {
      if (usingSavedCard) {
        final saved = _cards.where((c) => c.id == _selectedCardId).firstOrNull;
        if (saved != null) {
          cardNumber = saved.cardNumberHash ?? saved.lastFour;
          cardExpiry = '${saved.expiryMonth}/${saved.expiryYear}';
          cardCvc    = saved.cvc;
        }
      } else {
        cardNumber = '4242424242424242';
        cardExpiry = '12/99';
        cardCvc    = '000';
      }
    }

    final res = await placeOrder(
      items: items,
      customerName: user?.name,
      customerEmail: user?.email,
      customerPhone: user?.phone,
      deliveryAddressId: _selectedAddress?.id,
      deliveryDate: dateStr,
      deliveryTimeSlot: _timeSlot,
      term: term,
      paymentMethod: _paymentMethod,
      cardNumber: cardNumber,
      cardExpiry: cardExpiry,
      cardCvc:    cardCvc,
      promoCode: promo,
      notes: notes,
    );

    if (!mounted) return;

    if (!res.success || res.data == null) {
      setState(() {
        _error = res.message ?? res.error ?? 'Failed to place order. Please try again.';
        _submitting = false;
      });
      return;
    }

    final order = res.data!;

    final payRes = await initiatePayment(
      orderId: order.id,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    if (!payRes.success || payRes.data == null) {
      setState(() {
        _error = payRes.message ?? payRes.error ?? 'Failed to initiate payment. Please try again.';
        _submitting = false;
      });
      return;
    }

    final payment = payRes.data!;
    final clientSecret = payment.clientSecret ?? '';
    debugPrint('[Checkout._submit] paymentMethod=$_paymentMethod usingSavedCard=$usingSavedCard clientSecret=${clientSecret.isNotEmpty ? "present" : "MISSING"}');

    if (_paymentMethod == 'card' && _needsNewCard && clientSecret.isNotEmpty) {
      // New card: confirm the PaymentIntent right here against the still-
      // mounted Stripe CardField — no separate screen, no browser redirect.
      setState(() { _submitting = false; _confirmingCard = true; });
      try {
        await stripe.Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: stripe.PaymentMethodParams.card(
            paymentMethodData: stripe.PaymentMethodData(
              billingDetails: stripe.BillingDetails(
                name: user?.name,
                email: user?.email,
                phone: user?.phone,
              ),
            ),
          ),
        );
        if (!mounted) return;
        setState(() => _confirmingCard = false);
        context.read<CartState>().clearBackend();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order, subtotal: widget.subtotal, vat: widget.vat)),
        );
      } on stripe.StripeException catch (e) {
        debugPrint('[Checkout._submit] StripeException: code=${e.error.code} message=${e.error.message} localized=${e.error.localizedMessage}');
        if (!mounted) return;
        final canceled = e.error.code == stripe.FailureCode.Canceled;
        setState(() {
          _confirmingCard = false;
          _error = canceled ? 'Payment canceled.' : (e.error.localizedMessage ?? e.error.message ?? 'Payment failed. Please try again.');
        });
      } catch (e) {
        debugPrint('[Checkout._submit] error: $e');
        if (!mounted) return;
        setState(() { _confirmingCard = false; _error = 'Payment failed. Please try again.'; });
      }
      return;
    }

    setState(() => _submitting = false);

    // Saved card / Apple Pay / Google Pay: no inline confirmation path wired
    // up yet — fall back to the hosted-checkout redirect + poll flow, same
    // as myWeb2 does for these methods.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PaymentProcessingScreen(
        payment: payment,
        order: order,
        subtotal: widget.subtotal,
        vat: widget.vat,
      )),
    );
  }

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);

    return Stack(
      children: [
        _buildScaffold(s),
        if (_confirmingCard) _buildConfirmingOverlay(),
      ],
    );
  }

  Widget _buildConfirmingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 38),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(PwtRadius.lg),
              boxShadow: const [BoxShadow(color: Color(0x140F1E50), blurRadius: 30, offset: Offset(0, 14))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: PwtColors.brandTint, shape: BoxShape.circle),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3, color: PwtColors.brand),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                ExcludeSemantics(
                  child: Text(
                    'Confirming Your Payment',
                    textAlign: TextAlign.center,
                    style: PwtType.title().copyWith(fontSize: 18, decoration: TextDecoration.none),
                  ),
                ),
                const SizedBox(height: 10),
                ExcludeSemantics(
                  child: Text(
                    "Please don't close or refresh this screen while we securely confirm your payment with Stripe.",
                    textAlign: TextAlign.center,
                    style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 12.5, height: 1.5, decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(Map<String, String> s) {
    final app = context.watch<AppState>();
    return DetailScaffold(
      title: s['checkout'],
      body: Column(
        children: [
          _buildStepBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (_step == 0) ..._buildInfoStep(s, app.isArabic),
                if (_step == 1) ..._buildDeliveryStep(s),
                if (_step == 2) ..._buildPaymentStep(s),
              ],
            ),
          ),
        ],
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: PwtColors.errorFill,
                border: Border.all(color: PwtColors.errorBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: PwtColors.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: PwtColors.error), maxLines: 3, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          PwtButton(
            label: _submitting ? 'Placing order…' : (_step < 2 ? 'Continue' : s['placeOrder']!),
            full: true,
            trailing: _step < 2 ? PwtIcons.arrow : null,
            disabled: !_canProceed || _submitting,
            onPressed: _step < 2
                ? () {
                    if (_step == 1 && _paymentMethod == 'card' && _cards.isEmpty) _loadCards();
                    setState(() { _step++; _error = null; _dateError = null; });
                  }
                : _submit,
          ),
        ],
      ),
    );
  }

  // ── Step indicator ──
  Widget _buildStepBar() {
    const labels = ['Information', 'Delivery', 'Payment'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) Expanded(
              child: Container(
                height: 2,
                color: i <= _step ? PwtColors.brand : PwtColors.hairline2,
              ),
            ),
            _StepDot(index: i + 1, active: i == _step, done: i < _step, label: labels[i]),
          ],
        ],
      ),
    );
  }

  // ── Step 0 – Information ──
  List<Widget> _buildInfoStep(Map<String, String> s, bool ar) {
    return [
      Section(
        title: s['orderSummary']!,
        child: PwtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < widget.rows.length; i++)
                _summaryItem(widget.rows[i], s, ar, last: i == widget.rows.length - 1),
            ],
          ),
        ),
      ),
      Section(
        title: 'Delivery Address',
        child: _buildAddressSection(),
      ),
    ];
  }

  Widget _buildAddressSection() {
    if (_loadingAddresses) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
      );
    }
    if (_addressError != null) {
      return PwtBanner(variant: BannerVariant.error, title: 'Could not load addresses', body: _addressError!);
    }
    if (_addresses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwtBanner(variant: BannerVariant.info, title: 'No saved addresses', body: 'Please add a delivery address in your profile to continue.'),
          const SizedBox(height: 12),
          PwtButton(
            label: 'Add an Address',
            variant: PwtButtonVariant.secondary,
            size: PwtButtonSize.md,
            icon: PwtIcons.plus,
            onPressed: _openProfileToAddAddress,
          ),
        ],
      );
    }
    return Column(
      children: [
        for (final addr in _addresses)
          GestureDetector(
            onTap: () => setState(() => _selectedAddress = addr),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PwtColors.surface,
                border: Border.all(
                  color: _selectedAddress?.id == addr.id ? PwtColors.brand : PwtColors.hairline,
                  width: _selectedAddress?.id == addr.id ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(PwtRadius.card),
              ),
              child: Row(
                children: [
                  Icon(PwtIcons.pin, size: 20, color: _selectedAddress?.id == addr.id ? PwtColors.brand : PwtColors.textTer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(addr.label ?? 'Address', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14)),
                            if (addr.isDefault == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(999)),
                                child: Text('Default', style: PwtType.caption().copyWith(fontSize: 10, color: PwtColors.brand, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [addr.line1, addr.city, addr.country?.name].where((v) => v != null && v.isNotEmpty).join(', '),
                          style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 12.5),
                        ),
                        if (addr.recipientName != null || addr.recipientPhone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            [addr.recipientName, addr.recipientPhone].where((v) => v != null && v!.isNotEmpty).join(' · '),
                            style: PwtType.caption().copyWith(fontSize: 11.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_selectedAddress?.id == addr.id)
                    const Icon(Icons.check_circle, size: 20, color: PwtColors.brand),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Step 1 – Delivery ──
  List<Widget> _buildDeliveryStep(Map<String, String> s) {
    Widget slotBtn(String value, String label, String sub) {
      final on = _timeSlot == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _timeSlot = value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: on ? PwtColors.brand : PwtColors.surface,
              border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: on ? Colors.white : PwtColors.textPri)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 11, color: on ? Colors.white.withValues(alpha: .8) : PwtColors.textTer)),
              ],
            ),
          ),
        ),
      );
    }

    return [
      Section(
        title: 'Preferred Delivery Date',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () { _pickDate(); setState(() => _dateError = null); },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PwtColors.surface,
                borderRadius: BorderRadius.circular(PwtRadius.md),
                border: Border.all(
                  color: _dateError != null ? PwtColors.error : PwtColors.hairline,
                  width: _dateError != null ? 1.5 : 1,
                ),
                boxShadow: PwtShadows.e1,
              ),
              child: Row(children: [
                Icon(PwtIcons.cal, size: 20, color: _dateError != null ? PwtColors.error : PwtColors.brand),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _deliveryDate != null ? _fmtDate(_deliveryDate!) : 'Select a date…',
                    style: _deliveryDate != null
                        ? PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14)
                        : PwtType.body(color: PwtColors.textTer).copyWith(fontSize: 14),
                  ),
                ),
                const Icon(PwtIcons.caret, size: 16, color: PwtColors.textTer),
              ]),
            ),
          ),
          if (_dateError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2),
              child: Text(_dateError!, style: PwtType.body(color: PwtColors.error).copyWith(fontSize: 12)),
            ),
        ]),
      ),
      Section(
        title: 'Preferred Time Slot',
        child: Row(
          children: [
            slotBtn('morning', 'Morning', '6 AM – 12 PM'),
            const SizedBox(width: 8),
            slotBtn('afternoon', 'Afternoon', '12 PM – 6 PM'),
            const SizedBox(width: 8),
            slotBtn('evening', 'Evening', '6 PM – 10 PM'),
          ],
        ),
      ),
    ];
  }

  // ── Step 2 – Payment ──
  List<Widget> _buildPaymentStep(Map<String, String> s) {
    Widget methodBtn(String value, String label, IconData icon) {
      final on = _paymentMethod == value;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() { _paymentMethod = value; });
            if (value == 'card' && _cards.isEmpty && !_loadingCards) _loadCards();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: on ? PwtColors.brandTint : PwtColors.surface,
              border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline, width: on ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: on ? PwtColors.brand : PwtColors.textSec),
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? PwtColors.brand : PwtColors.textPri)),
              ],
            ),
          ),
        ),
      );
    }

    return [
      Section(
        title: s['paymentMethod']!,
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // methodBtn('cod', 'Cash on Delivery', Icons.money_outlined),
                  // const SizedBox(width: 10),
                  methodBtn('card', 'Credit / Debit Card', Icons.credit_card_outlined),
                  const SizedBox(width: 10),
                  methodBtn('apple_pay', 'Apple Pay', Icons.apple),
                  const SizedBox(width: 10),
                  methodBtn('google_pay', 'Google Pay', Icons.account_balance_wallet_outlined),
                ],
              ),
            ),
            if (_paymentMethod == 'card') ...[
              const SizedBox(height: 16),
              _buildCardSection(),
            ],
          ],
        ),
      ),
      Section(
        title: 'Promo Code',
        child: PwtCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: _promoCtrl,
            textCapitalization: TextCapitalization.characters,
            style: PwtType.mono(size: 14),
            decoration: const InputDecoration(
              hintText: 'Enter promo code',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ),
      Section(
        title: 'Notes',
        child: PwtCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: _notesCtrl,
            maxLines: 3,
            style: PwtType.body(color: PwtColors.textPri).copyWith(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Any notes for delivery or installation…',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ),
      Section(
        title: s['total']!,
        child: PwtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SummaryRow(label: s['subtotal']!, value: _money(widget.subtotal, PwtColors.textSec)),
              SummaryRow(label: s['shippingFee']!, value: Text(s['free']!, style: const TextStyle(color: PwtColors.success, fontWeight: FontWeight.w600))),
              SummaryRow(label: s['vat']!, value: _money(widget.vat, PwtColors.textSec)),
              SummaryRow(label: s['total']!, bold: true, last: true, value: _money(widget.subtotal + widget.vat, PwtColors.textPri)),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildCardSection() {
    if (_loadingCards) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_cards.isNotEmpty) ...[
          for (final c in _cards)
            GestureDetector(
              onTap: () => setState(() { _selectedCardId = c.id; _enterNewCard = false; }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PwtColors.surface,
                  border: Border.all(
                    color: !_enterNewCard && _selectedCardId == c.id ? PwtColors.brand : PwtColors.hairline,
                    width: !_enterNewCard && _selectedCardId == c.id ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(PwtRadius.card),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF4A52A3)]),
                      ),
                      alignment: Alignment.center,
                      child: Text(c.brand.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text('${c.brand} ···· ${c.lastFour}', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14)),
                          ),
                          Text('${c.cardholderName} · Exp ${c.expiryMonth}/${c.expiryYear}', style: PwtType.caption().copyWith(fontSize: 11.5)),
                        ],
                      ),
                    ),
                    if (c.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(999)),
                        child: Text('Default', style: PwtType.caption().copyWith(fontSize: 10, color: PwtColors.brand, fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(width: 8),
                    if (!_enterNewCard && _selectedCardId == c.id)
                      const Icon(Icons.check_circle, size: 20, color: PwtColors.brand),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() { _enterNewCard = !_enterNewCard; _selectedCardId = null; }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(_enterNewCard ? Icons.remove_circle_outline : Icons.add_circle_outline, size: 18, color: PwtColors.brand),
                  const SizedBox(width: 8),
                  Text(_enterNewCard ? 'Use a saved card' : 'Use a new card', style: PwtType.label(color: PwtColors.brand, weight: FontWeight.w600).copyWith(fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ],
        if (_needsNewCard) ...[
          Text('Card Details', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: PwtColors.surface,
              borderRadius: BorderRadius.circular(PwtRadius.card),
              border: Border.all(
                color: _cardTouched && !_cardComplete ? PwtColors.error : PwtColors.hairline,
                width: _cardTouched && !_cardComplete ? 1.5 : 1,
              ),
              boxShadow: PwtShadows.e1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: stripe.CardField(
              enablePostalCode: false,
              style: PwtType.body(color: PwtColors.textPri).copyWith(fontSize: 14.5),
              cursorColor: PwtColors.brand,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 8),
              ),
              onCardChanged: (details) => setState(() {
                _cardComplete = details?.complete ?? false;
                _cardTouched = true;
              }),
            ),
          ),
          if (_cardTouched && !_cardComplete) ...[
            const SizedBox(height: 6),
            Text('Enter your card details to continue.', style: PwtType.body(color: PwtColors.error).copyWith(fontSize: 12)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 14, color: PwtColors.textTer),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your card details are securely encrypted by Stripe.',
                  style: PwtType.caption().copyWith(fontSize: 11.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _summaryItem(_ApiRow r, Map<String, String> s, bool ar, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: PwtColors.hairline))),
      child: Row(
        children: [
          Container(
            width: 44, height: 56,
            decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: PwtColors.hairline)),
            alignment: Alignment.center,
            child: r.product.primaryImageUrl != null && r.product.primaryImageUrl!.isNotEmpty
                ? Image.network(r.product.primaryImageUrl!, height: 42, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 22, color: PwtColors.brand))
                : const Icon(PwtIcons.drop, size: 22, color: PwtColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.product.localizedName ?? r.product.name?.toString() ?? r.product.code ?? '', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text('${r.plan == Plan.rent ? s['rent'] : s['buy']} · ${ar ? 'كمية' : 'Qty'} ${r.qty}', style: PwtType.caption().copyWith(fontSize: 11.5)),
              ],
            ),
          ),
          _money(r.unit * r.qty, PwtColors.textPri, size: 14),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.active, required this.done, required this.label});
  final int index;
  final bool active;
  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? PwtColors.brand : PwtColors.surface,
            border: Border.all(color: active || done ? PwtColors.brand : PwtColors.hairline2, width: 2),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text('$index', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : PwtColors.textTer)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? PwtColors.brand : PwtColors.textTer)),
      ],
    );
  }
}

// ─── Payment processing ───
class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.payment,
    required this.order,
    required this.subtotal,
    required this.vat,
  });
  final PaymentModel payment;
  final OrderDetailModel order;
  final double subtotal;
  final double vat;

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> with WidgetsBindingObserver {
  Timer? _timer;
  int _attempts = 0;
  String? _error;
  static const _maxAttempts = 30; // 30 × 3 s = 90 s

  bool get _useStripeSheet => (widget.payment.clientSecret ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[PaymentProcessing] useStripeSheet=$_useStripeSheet clientSecret=${_useStripeSheet ? "present" : "MISSING"} paymentUrl=${widget.payment.paymentUrl}');
    if (_useStripeSheet) {
      // Presenting the sheet synchronously from initState — before this
      // screen has actually been laid out/attached — can make the native
      // call silently no-op on some devices. Defer it to right after the
      // first frame so the Activity is definitely resumed and attached.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startStripePaymentSheet();
      });
    } else {
      _openPaymentUrl();
      _startPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Payment happens in an external browser/app; our background poll can
  // exhaust its attempt limit while the user is still completing payment
  // there. Re-check the moment the app comes back to the foreground so a
  // slow (but successful) payment doesn't get reported as timed out.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!mounted) return;
    if (_timer == null || !_timer!.isActive) {
      setState(() => _error = null);
      _startPolling();
    }
  }

  void _startPolling() {
    _attempts = 0;
    _timer?.cancel();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _openPaymentUrl() async {
    final url = widget.payment.paymentUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the payment page. Tap the button below to retry.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to launch payment url "$url": $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the payment page: $e')),
        );
      }
    }
  }

  Future<void> _startStripePaymentSheet() async {
    setState(() => _error = null);
    try {
      debugPrint('[StripePaymentSheet] initPaymentSheet…');
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: widget.payment.clientSecret!,
          merchantDisplayName: 'Pure Water Technology',
          // Temporarily disabled to isolate a generic, detail-less
          // presentPaymentSheet() failure on a MIUI/Xiaomi device that may
          // lack working Google Play Services — Stripe's SDK does a Google
          // Pay availability check as part of sheet setup even if the user
          // never taps the Google Pay button.
          // googlePay: const stripe.PaymentSheetGooglePay(merchantCountryCode: 'AE', testEnv: true),
        ),
      );
      if (!mounted) return;
      debugPrint('[StripePaymentSheet] presentPaymentSheet…');
      await stripe.Stripe.instance.presentPaymentSheet();
      debugPrint('[StripePaymentSheet] presentPaymentSheet completed — payment confirmed.');
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      context.read<CartState>().clearBackend();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: widget.order, subtotal: widget.subtotal, vat: widget.vat)),
      );
    } on stripe.StripeException catch (e) {
      debugPrint('[StripePaymentSheet] StripeException: code=${e.error.code} type=${e.error.type} stripeErrorCode=${e.error.stripeErrorCode} declineCode=${e.error.declineCode} message=${e.error.message} localized=${e.error.localizedMessage}');
      if (!mounted) return;
      final canceled = e.error.code == stripe.FailureCode.Canceled;
      setState(() => _error = canceled ? 'Payment canceled.' : (e.error.localizedMessage ?? e.error.message ?? 'Payment failed. Please try again.'));
    } catch (e) {
      debugPrint('[StripePaymentSheet] error: $e');
      if (!mounted) return;
      setState(() => _error = 'Payment failed. Please try again.');
    }
  }

  Future<void> _poll() async {
    if (!mounted) return;
    _attempts++;
    if (_attempts > _maxAttempts) {
      _timer?.cancel();
      if (mounted) setState(() => _error = 'Payment is taking longer than expected. Please check your orders or try again.');
      return;
    }

    final res = await getPaymentStatus(widget.payment.paymentId);
    if (!mounted) return;
    if (!res.success || res.data == null) return;

    final status = res.data!;
    if (status.isCaptured) {
      _timer?.cancel();
      // ignore: use_build_context_synchronously
      context.read<CartState>().clearBackend();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: widget.order, subtotal: widget.subtotal, vat: widget.vat)),
      );
    } else if (status.isFailed) {
      _timer?.cancel();
      setState(() => _error = status.failureReason ?? 'Payment failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DetailScaffold(
      title: _error != null ? 'Payment Failed' : 'Processing Payment',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                const Icon(Icons.error_outline, size: 56, color: Color(0xFFDC2626)),
                const SizedBox(height: 20),
                Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFFDC2626)), textAlign: TextAlign.center),
                const SizedBox(height: 28),
                if (_useStripeSheet) ...[
                  PwtButton(label: 'Try Again', full: true, onPressed: _startStripePaymentSheet),
                  const SizedBox(height: 12),
                ],
                PwtButton(
                  label: 'Go Back',
                  full: true,
                  variant: _useStripeSheet ? PwtButtonVariant.ghost : PwtButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 28),
                Text('Processing Payment…', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  _useStripeSheet
                      ? 'Please wait while we confirm your payment.\nDo not close this screen.'
                      : (widget.payment.paymentUrl != null && widget.payment.paymentUrl!.isNotEmpty
                          ? 'Complete your payment in the browser that just opened.\nDo not close this screen.'
                          : 'Please wait while we confirm your payment.\nDo not close this screen.'),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (!_useStripeSheet && widget.payment.paymentUrl != null && widget.payment.paymentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _openPaymentUrl,
                    child: const Text("Didn't see the payment page? Open it again"),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Order confirmed ───
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order, required this.subtotal, required this.vat});
  final OrderDetailModel order;
  final double subtotal;
  final double vat;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);

    return DetailScaffold(
      title: s['orderConfirmed'],
      onBack: () => Navigator.of(context).popUntil((r) => r.isFirst),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SuccessView(
            title: s['orderConfirmed']!,
            body: s['orderConfirmedSub']!,
            detail: Directionality(
              textDirection: TextDirection.ltr,
              child: Text('Order #${order.displayName??order.id}', style: PwtType.mono(size: 12, color: PwtColors.brand, weight: FontWeight.w600)),
            ),
          ),
          Section(
            title: s['total']!,
            child: PwtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SummaryRow(label: s['subtotal']!, value: _money(double.tryParse(order.subtotalAmount) ?? subtotal, PwtColors.textSec)),
                  SummaryRow(label: s['vat']!, value: _money(double.tryParse(order.taxAmount) ?? vat, PwtColors.textSec)),
                  SummaryRow(label: s['total']!, bold: true, last: true, value: _money(double.tryParse(order.totalAmount) ?? (subtotal + vat), PwtColors.textPri)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                // PwtButton(label: s['viewOrder']!, full: true, onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                // const SizedBox(height: 10),
                PwtButton(label: s['continueShopping']!, variant: PwtButtonVariant.ghost, full: true, onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quotation submitted ───
class QuotationSuccessScreen extends StatelessWidget {
  const QuotationSuccessScreen({super.key, required this.rows, required this.role});
  final List<_ApiRow> rows;
  final AccountKind role;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final orderId = _genOrderId(AccountKind.business);

    return DetailScaffold(
      title: s['quotationSubmitted'],
      onBack: () => Navigator.of(context).popUntil((r) => r.isFirst),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SuccessView(
            title: s['quotationSubmitted']!,
            body: s['quotationSubmittedSub']!,
            icon: PwtIcons.message,
            accent: PwtColors.brand,
            detail: Directionality(
              textDirection: TextDirection.ltr,
              child: Text('${s['orderId']}  $orderId', style: PwtType.mono(size: 12, color: PwtColors.brand, weight: FontWeight.w600)),
            ),
          ),
          Section(
            title: app.isArabic ? 'العناصر المطلوبة' : 'Requested items',
            child: PwtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(border: i == rows.length - 1 ? null : const Border(bottom: BorderSide(color: PwtColors.hairline))),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 50,
                            decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: PwtColors.hairline)),
                            alignment: Alignment.center,
                            child: rows[i].product.primaryImageUrl != null && rows[i].product.primaryImageUrl!.isNotEmpty
                                ? Image.network(rows[i].product.primaryImageUrl!, height: 38, fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 20, color: PwtColors.brand))
                                : const Icon(PwtIcons.drop, size: 20, color: PwtColors.brand),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rows[i].product.localizedName ?? rows[i].product.name?.toString() ?? rows[i].product.code ?? '', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13.5))),
                          Text('${app.isArabic ? 'كمية' : 'Qty'} ${rows[i].qty}', style: PwtType.caption().copyWith(fontSize: 11.5)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: PwtBanner(
              variant: BannerVariant.info,
              title: app.isArabic ? 'الخطوات التالية' : 'What happens next',
              body: app.isArabic
                  ? 'سيراجع فريقنا متطلباتك ويرسل عرض السعر مع تفاصيل التركيب خلال 24 ساعة عمل.'
                  : 'Our team will review your requirements and send a tailored quote with installation details within 24 working hours.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                // PwtButton(label: s['viewOrder']!, full: true, onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                // const SizedBox(height: 10),
                PwtButton(label: s['continueShopping']!, variant: PwtButtonVariant.ghost, full: true, onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
