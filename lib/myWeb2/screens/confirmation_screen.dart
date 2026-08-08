import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';
import '../../Models/Orders/order_model.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  String get _dashRoute => AppState.instance.isCompany ? '/companyDashboard' : '/dashboard';

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as OrderDetailModel?;
    final orderId = order?.displayName ?? '—';
    final currency = order?.currency ?? 'AED';
    final total = order?.totalAmount ?? '0.00';
    final items = order?.items ?? [];

    return StoreScaffold(active: '/', showFooter: false, slivers: [
      SliverToBoxAdapter(
        child: Band(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(children: [
          Container(
            width: 84, height: 84,
            decoration: const BoxDecoration(color: AppColors.badgeGreenBg, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 44, color: AppColors.green600),
          ),
          const SizedBox(height: 18),
          Text('Order placed successfully', style: AppText.headline(30), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Thank you. Your order has been placed successfully. A confirmation email is on its way with all the details.',
            style: AppText.bodyLg.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          // Order reference chip
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: orderId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order ID copied'), duration: Duration(seconds: 2)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Order ID  ', style: AppText.muted),
                Flexible(child: Text(orderId, style: AppText.label, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                const Icon(Icons.copy, size: 15, color: AppColors.ink400),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          // Next steps banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.blue700),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated Delivery & Installation', style: AppText.h3.copyWith(fontSize: 15)),
                const SizedBox(height: 3),
                Text('Our team will contact you to confirm your delivery and installation slot.', style: AppText.body.copyWith(color: AppColors.ink600)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          // Order summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order Summary', style: AppText.h3),
              const SizedBox(height: 12),
              if (items.isNotEmpty)
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.water_drop_outlined, size: 24, color: AppColors.blue200),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.productNameSnapshot, style: AppText.label),
                      Text('Qty ${item.quantity}', style: AppText.muted),
                    ])),
                    Text('$currency ${item.lineTotal}', style: AppText.label),
                  ]),
                ))
              else
                Text('${order?.itemsCount ?? 1} item(s) ordered', style: AppText.body.copyWith(color: AppColors.ink600)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppColors.line)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total Paid', style: AppText.h3),
                Text('$currency $total', style: AppText.h2.copyWith(fontSize: 20)),
              ]),
            ]),
          ),
          const SizedBox(height: 22),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            PwtButton('Track Order', icon: Icons.location_on_outlined, onPressed: () => order != null
                ? Navigator.of(context).pushNamedAndRemoveUntil('/orderDetail', (r) => false, arguments: order.id)
                : Navigator.of(context).pushNamedAndRemoveUntil(_dashRoute, (r) => false)),
            PwtButton('Go to Dashboard', variant: PwtBtn.outline, icon: Icons.grid_view_rounded, onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(_dashRoute, (r) => false)),
            PwtButton('Continue Shopping', variant: PwtBtn.ghost, onPressed: () => Navigator.of(context).pushNamed('/shop')),
          ]),
          const SizedBox(height: 18),
          Text('Need help with your order? Contact our support team.', style: AppText.muted, textAlign: TextAlign.center),
        ])))),
      ),
    ]);
  }
}
