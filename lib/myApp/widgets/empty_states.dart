// Empty states shared by the shells — ported from lib/test/widgets/empty_states.dart
// (the DevicesEmptyState / OrdersEmptyState design), adapted to use real
// fetched product data instead of mock data.
//
// All are pure presentation: hand them an `onBrowse` callback (and, for
// devices, a few teaser products already fetched by the caller) and they
// slot into any ListView.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/Products/products_model.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../i18n/strings.dart';
import '../state/app_state.dart';
import 'primitives.dart';
import 'pwt_icons.dart';
import 'trial_strip.dart';

/// Circular brand medallion used as the illustration slot in every empty state.
class EmptyMedallion extends StatelessWidget {
  const EmptyMedallion({super.key, required this.icon, this.size = 120, this.iconSize = 56});
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: PwtColors.brandTint,
          shape: BoxShape.circle,
          border: Border.all(color: PwtColors.brandBorder),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: PwtColors.brand),
      ),
    );
  }
}

/// Devices / fleet empty state. `business: true` swaps the product teaser
/// tiles for the three-step "how it works" list, since a fleet starts with
/// a quote. [teaserProducts] should be a few already-fetched products (only
/// used when `business` is false).
class DevicesEmptyState extends StatelessWidget {
  const DevicesEmptyState({super.key, required this.business, required this.onBrowse, this.teaserProducts = const []});
  final bool business;
  final VoidCallback onBrowse;
  final List<ProductModel> teaserProducts;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return Padding(
      padding: EdgeInsets.fromLTRB(30, business ? 28 : 40, 30, 0),
      child: Column(
        children: [
          const EmptyMedallion(icon: PwtIcons.drop),
          const SizedBox(height: 22),
          Text(
            business ? s['noFleetYet']! : s['noDevicesYet']!,
            textAlign: TextAlign.center,
            style: PwtType.title().copyWith(fontSize: 22, letterSpacing: -.4),
          ),
          const SizedBox(height: 8),
          Text(
            business ? s['noFleetSub']! : s['noDevicesSub']!,
            textAlign: TextAlign.center,
            style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 18),
          const TrialStrip(),
          SizedBox(height: business ? 14 : 18),
          if (business) const _HowItWorksSteps() else if (teaserProducts.isNotEmpty) _ProductTeaserTiles(products: teaserProducts),
          const SizedBox(height: 22),
          PwtButton(label: s['exploreProducts']!, full: true, icon: PwtIcons.arrow, onPressed: onBrowse),
          SizedBox(height: business ? 40 : 8),
        ],
      ),
    );
  }
}

class _HowItWorksSteps extends StatelessWidget {
  const _HowItWorksSteps();

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final steps = [s['emptyBizStep1']!, s['emptyBizStep2']!, s['emptyBizStep3']!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s['emptyHowItWorks']!.toUpperCase(),
          style: PwtType.eyebrow(color: PwtColors.textTer).copyWith(fontSize: 10.5, letterSpacing: 1, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: PwtColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PwtColors.hairline),
                boxShadow: PwtShadows.e1,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: PwtColors.brandTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: PwtColors.brandBorder),
                    ),
                    child: Text('${i + 1}', style: PwtType.mono(color: PwtColors.brand).copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14, letterSpacing: -.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
                color: PwtColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PwtColors.hairline),
                boxShadow: PwtShadows.e1,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 66,
                    child: products[i].primaryImageUrl != null
                        ? Image.network(
                            products[i].primaryImageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 40, color: PwtColors.brandBorder),
                          )
                        : const Icon(PwtIcons.drop, size: 40, color: PwtColors.brandBorder),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    products[i].name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 11),
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

/// Orders empty state (Orders tab, individual or business).
class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 34, 10, 0),
      child: Column(
        children: [
          const EmptyMedallion(icon: PwtIcons.orders, size: 104, iconSize: 46),
          const SizedBox(height: 20),
          Text(s['noOrdersYet']!, textAlign: TextAlign.center, style: PwtType.title().copyWith(fontSize: 21, letterSpacing: -.4)),
          const SizedBox(height: 8),
          Text(
            s['noOrdersSub']!,
            textAlign: TextAlign.center,
            style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 18),
          const TrialStrip(),
          const SizedBox(height: 20),
          PwtButton(label: s['exploreProducts']!, full: true, icon: PwtIcons.arrow, onPressed: onBrowse),
        ],
      ),
    );
  }
}
