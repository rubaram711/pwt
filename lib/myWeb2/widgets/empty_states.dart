// Empty states for the dashboard machines/orders lists — ported 1:1 from
// lib/myApp/widgets/empty_states.dart (the DevicesEmptyState / OrdersEmptyState
// design), restyled with myWeb2's web design tokens (AppColors/AppText/PwtButton)
// so both apps show the exact same empty-state page.

import 'package:flutter/material.dart';
import '../../Models/Products/products_model.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'trial_strip.dart';

/// Circular brand medallion used as the illustration slot in every empty state.
class EmptyMedallion extends StatelessWidget {
  const EmptyMedallion({super.key, required this.icon, this.size = 72, this.iconSize = 32});
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.blue50,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.blue200),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: AppColors.blue700),
    );
  }
}

/// Machines / fleet empty state. `business: true` swaps the product teaser
/// tiles for the three-step "how it works" list, since a company fleet
/// starts with a quotation rather than a self-serve purchase.
/// [teaserProducts] should be a few already-fetched products (only used
/// when `business` is false). Structure/copy mirrors myApp's
/// DevicesEmptyState exactly.
class DevicesEmptyState extends StatelessWidget {
  const DevicesEmptyState({super.key, required this.business, required this.onBrowse, this.teaserProducts = const []});
  final bool business;
  final VoidCallback onBrowse;
  final List<ProductModel> teaserProducts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, business ? 28 : 40, 30, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            EmptyMedallion(icon: Icons.water_drop_outlined, size: 120, iconSize: 56),
            const SizedBox(height: 22),
            Text(
              business ? 'Your fleet is empty' : 'No machines yet',
              textAlign: TextAlign.center,
              style: AppText.h2.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              business
                  ? 'Request a quotation for your office or facility — we\'ll handle install + setup.'
                  : 'Browse the PWT catalogue and add your first machine.',
              textAlign: TextAlign.center,
              style: AppText.muted.copyWith(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 18),
            const TrialStrip(),
            SizedBox(height: business ? 14 : 18),
            if (business) const _HowItWorksSteps() else if (teaserProducts.isNotEmpty) _ProductTeaserTiles(products: teaserProducts),
            const SizedBox(height: 22),
            PwtButton('Explore Products', icon: Icons.arrow_forward, fullWidth: true, onPressed: onBrowse),
            SizedBox(height: business ? 40 : 8),
          ],
        ),
      ),
    );
  }
}

class _ProductTeaserTiles extends StatelessWidget {
  const _ProductTeaserTiles({required this.products});
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < products.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 66,
                    child: products[i].primaryImageUrl != null
                        ? Image.network(
                            products[i].primaryImageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 40, color: AppColors.blue200),
                          )
                        : const Icon(Icons.water_drop_outlined, size: 40, color: AppColors.blue200),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    products[i].name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HowItWorksSteps extends StatelessWidget {
  const _HowItWorksSteps();

  @override
  Widget build(BuildContext context) {
    const steps = ['Request a quotation', 'Install & setup', 'Manage & maintain'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOW IT WORKS', style: AppText.muted.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 10),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
                boxShadow: const [BoxShadow(color: Color(0x0A0F1E50), blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Row(children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.blue50, shape: BoxShape.circle, border: Border.all(color: AppColors.blue200)),
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blue700)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(steps[i], style: AppText.label)),
              ]),
            ),
          ),
      ],
    );
  }
}

/// Orders empty state (Orders tab, individual or company). Structure/copy
/// mirrors myApp's OrdersEmptyState exactly.
class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 34, 10, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            const EmptyMedallion(icon: Icons.receipt_long_outlined, size: 104, iconSize: 46),
            const SizedBox(height: 20),
            Text('No orders yet', textAlign: TextAlign.center, style: AppText.h2.copyWith(fontSize: 21)),
            const SizedBox(height: 8),
            Text(
              'Orders you place will show up here.',
              textAlign: TextAlign.center,
              style: AppText.muted.copyWith(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 18),
            const TrialStrip(),
            const SizedBox(height: 20),
            PwtButton('Explore Products', icon: Icons.arrow_forward, fullWidth: true, onPressed: onBrowse),
          ],
        ),
      ),
    );
  }
}
