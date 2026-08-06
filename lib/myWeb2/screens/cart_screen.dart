import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/product.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreScaffold(active: '/cart', slivers: [
      SliverToBoxAdapter(
        child: Band(child: AnimatedBuilder(
          animation: AppState.instance,
          builder: (context, _) {
            final s = AppState.instance;
            final wide = MediaQuery.of(context).size.width > 880;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Your Cart', style: AppText.headline(wide ? 32 : 26)),
                  const Spacer(),
                  if (s.cart.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => s.clearBackendCart(),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: AppColors.danger),
                      label: Text('Clear cart', style: AppText.muted.copyWith(color: AppColors.danger)),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Review your items and proceed to checkout.', style: AppText.bodyLg),
              const SizedBox(height: 24),
              if (s.cart.isEmpty)
                _empty()
              else
                Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: wide ? 3 : 0, child: Column(children: [
                    ...s.cart.map((l) => _line(s, l)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/shop'),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Continue shopping'),
                      ),
                    ),
                  ])),
                  SizedBox(width: wide ? 22 : 0, height: wide ? 0 : 22),
                  Expanded(flex: wide ? 2 : 0, child: _summary(s)),
                ]),
            ]);
          },
        )),
      ),
    ]);
  }

  Widget _line(AppState s, CartLine l) {
    final isRent = l.mode == 'rent';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 84, height: 84,
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(8),
          child: l.product.primaryImageUrl != null
              ? Image.network(l.product.primaryImageUrl!, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 36, color: AppColors.blue200))
              : const Icon(Icons.water_drop_outlined, size: 36, color: AppColors.blue200),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.product.code ?? '', style: AppText.h3),
          const SizedBox(height: 2),
          Text(l.product.shortDescription ?? '', style: AppText.muted),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isRent ? AppColors.badgeBlueBg : AppColors.soft,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              isRent ? 'Rental' : 'One-time Purchase',
              style: AppText.muted.copyWith(fontWeight: FontWeight.w700, color: isRent ? AppColors.blue700 : AppColors.ink600),
            ),
          ),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          moneyText(l.lineTotal, AppText.price, symbolSize: 15, suffix: isRent ? '/mo' : ''),
          const SizedBox(height: 10),
          Row(children: [
            _qtyBtn(Icons.remove, () => s.decQty(l)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${l.qty}', style: AppText.label)),
            _qtyBtn(Icons.add, () => s.incQty(l)),
          ]),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => s.removeLine(l),
            icon: const Icon(Icons.delete_outline, size: 15, color: AppColors.danger),
            label: Text('Remove', style: AppText.muted.copyWith(color: AppColors.danger)),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ]),
      ]),
    );
  }

  Widget _qtyBtn(IconData ic, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(width: 30, height: 30, decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 15, color: AppColors.ink700)),
      );

  Widget _summary(AppState s) {
    final hasPromo = s.promoValid && s.promoDiscount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Order Summary', style: AppText.h2.copyWith(fontSize: 19)),
        const SizedBox(height: 16),
        _row('Subtotal', moneyText(s.subtotal, AppText.label.copyWith(color: AppColors.ink900))),
        _row('Delivery', Text('Free', style: AppText.label.copyWith(color: AppColors.green600)), muted: true),
        _row('Installation', Text('Free', style: AppText.label.copyWith(color: AppColors.green600)), muted: true),
        _row('VAT (${_fmtPercent(s.vatRatePercent)}%)', moneyText(s.vat, AppText.label.copyWith(color: AppColors.ink900))),
        if (hasPromo)
          _row('Promo (${s.appliedPromoCode})', moneyText(s.promoDiscount, AppText.label.copyWith(color: AppColors.discount), prefix: '- ')),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.line)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total', style: AppText.h3),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            moneyText(s.total, AppText.h2.copyWith(fontSize: 22), symbolSize: 16),
            const SizedBox(width: 6),
            Text('incl. VAT', style: AppText.muted),
          ]),
        ]),
        const SizedBox(height: 16),
        // promo code input
        if (hasPromo)
          _appliedPromoChip(s)
        else ...[
          Row(children: [
            Expanded(
              child: TextField(
                controller: _promoCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Promo code',
                  errorText: s.promoError,
                ),
                onSubmitted: (_) => _applyPromo(s),
              ),
            ),
            const SizedBox(width: 8),
            s.promoLoading
                ? const SizedBox(width: 40, height: 40, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)))
                : PwtButton('Apply', variant: PwtBtn.outline, onPressed: () => _applyPromo(s)),
          ]),
        ],
        const SizedBox(height: 16),
        if (s.user == null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.blue200),
            ),
            child: Row(children: [
              const Icon(Icons.lock_outline, size: 16, color: AppColors.blue700),
              const SizedBox(width: 10),
              Expanded(child: Text('Sign in to proceed to checkout.', style: AppText.muted.copyWith(color: AppColors.blue700))),
            ]),
          ),
          const SizedBox(height: 10),
          PwtButton('Sign in to Checkout', icon: Icons.arrow_forward, fullWidth: true, onPressed: () => Navigator.of(context).pushNamed('/login')),
        ] else
          PwtButton('Proceed to Checkout', icon: Icons.arrow_forward, fullWidth: true, onPressed: () {
            final mode = s.cart.any((l) => l.mode == 'rent') ? 'rent' : 'buy';
            Navigator.of(context).pushNamed('/checkout', arguments: mode);
          }),
        const SizedBox(height: 16),
        ..._assure('Secure SSL encrypted checkout', Icons.lock_outline),
        ..._assure('14-day easy returns', Icons.swap_horiz),
        ..._assure('2 years full warranty', Icons.shield_outlined),
      ]),
    );
  }

  void _applyPromo(AppState s) {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    s.applyPromo(code);
  }

  Widget _appliedPromoChip(AppState s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.badgeGreenBg, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.green600),
        const SizedBox(width: 8),
        Expanded(child: Text('${s.appliedPromoCode} applied', style: AppText.label.copyWith(color: AppColors.green600))),
        GestureDetector(
          onTap: () { s.clearPromo(); _promoCtrl.clear(); },
          child: const Icon(Icons.close, size: 16, color: AppColors.green600),
        ),
      ]),
    );
  }

  List<Widget> _assure(String t, IconData ic) => [
        Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Icon(ic, size: 15, color: AppColors.ink400), const SizedBox(width: 9), Text(t, style: AppText.muted)])),
      ];

  Widget _row(String k, Widget v, {bool muted = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: AppText.body.copyWith(color: muted ? AppColors.ink400 : AppColors.ink700)),
          v,
        ]),
      );

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Container(width: 80, height: 80, decoration: const BoxDecoration(color: AppColors.soft, shape: BoxShape.circle), child: const Icon(Icons.shopping_cart_outlined, size: 36, color: AppColors.ink400)),
          const SizedBox(height: 18),
          Text('Your cart is empty', style: AppText.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text("Looks like you haven't added anything yet.", style: AppText.body.copyWith(color: AppColors.ink500)),
          const SizedBox(height: 18),
          PwtButton('Browse Products', onPressed: () => Navigator.of(context).pushNamed('/shop')),
        ]),
      ),
    );
  }
}

String _fmtPercent(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
