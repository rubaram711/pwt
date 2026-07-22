import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/site_chrome.dart';
import '../widgets/common.dart';

/// Shared page hero (eyebrow + title + lede) for inner storefront pages.
class PageHero extends StatelessWidget {
  final String crumb;
  final String eyebrow;
  final String title;
  final String lede;
  const PageHero({super.key, required this.crumb, required this.eyebrow, required this.title, required this.lede});
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;
    return Band(
      color: AppColors.soft,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 44),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          InkWell(onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false), child: Text('Home', style: AppText.muted.copyWith(color: AppColors.blue700))),
          Text('  ›  $crumb', style: AppText.muted),
        ]),
        const SizedBox(height: 18),
        Eyebrow(eyebrow),
        const SizedBox(height: 14),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Text(title, style: AppText.headline(wide ? 40 : 30))),
        const SizedBox(height: 16),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: Text(lede, style: AppText.bodyLg.copyWith(height: 1.6))),
      ]),
    );
  }
}

class SolutionsScreen extends StatelessWidget {
  const SolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;
    final useCases = [
      ['01', 'Home', 'Countertop and freestanding systems that deliver hot, cold and sparkling water straight from the tap.'],
      ['02', 'Office', 'Touch-free dispensers that keep teams hydrated while cutting plastic bottle waste and clutter.'],
      ['03', 'Hospitality', 'High-capacity systems producing up to 180 L/hr of chilled and sparkling water for hotels and restaurants.'],
      ['04', 'Industrial', 'Custom-engineered purification at scale, with remote chillers, monitoring and scheduled servicing.'],
    ];
    final caps = [
      [Icons.filter_alt, 'Multi-stage filtration', 'Sediment, carbon block and reverse-osmosis membranes reduce contaminants down to 0.0001 micron.'],
      [Icons.verified_outlined, 'Install & maintain', 'Professional installation, scheduled filter changes and proactive reminders — handled for you.'],
      [Icons.monitor_heart_outlined, '24/7 monitoring', 'Connected systems track water quality and filter life, protecting against leaks around the clock.'],
    ];
    return StoreScaffold(active: '/solutions', slivers: [
      const SliverToBoxAdapter(
        child: PageHero(
          crumb: 'Solutions',
          eyebrow: 'Solutions for Everyone',
          title: 'Pure water, tailored to how you live and work.',
          lede: "Whether it's a single tap at home or hundreds of litres an hour for a busy restaurant, PWT has a purification solution built around your needs.",
        ),
      ),
      SliverToBoxAdapter(
        child: Band(child: Wrap(spacing: 20, runSpacing: 20, children: [
          SizedBox(width: wide ? 540 : double.infinity, child: _PathCard(icon: Icons.person_outline, title: 'For Individuals', intro: 'Buy or rent premium purification systems for your home, with installation and filter care included.', points: const ['Instant purchase or flexible rental', 'Free 7-day trial on rentals', 'Fast delivery & installation'], cta: 'Shop Now', solid: true, onTap: () => Navigator.of(context).pushNamed('/shop'))),
          SizedBox(width: wide ? 540 : double.infinity, child: _PathCard(icon: Icons.apartment, title: 'For Companies', intro: 'Customised quotations, volume pricing and a dedicated account manager for your business premises.', points: const ['Personalised pricing & bulk orders', 'Dedicated account manager', 'Priority maintenance & support'], cta: 'Request a Quotation', solid: false, onTap: () => Navigator.of(context).pushNamed('/rfq'))),
        ])),
      ),
      SliverToBoxAdapter(
        child: Band(color: AppColors.soft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('Where We Fit'),
          const SizedBox(height: 12),
          Text('Built for every environment', style: AppText.pageTitle.copyWith(fontSize: wide ? 28 : 23)),
          const SizedBox(height: 26),
          Wrap(spacing: 18, runSpacing: 18, children: useCases.map((u) => SizedBox(
                width: wide ? 270 : double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u[0], style: AppText.pageTitle.copyWith(color: AppColors.blue200, fontSize: 30)),
                    const SizedBox(height: 8),
                    Text(u[1], style: AppText.h3),
                    const SizedBox(height: 8),
                    Text(u[2], style: AppText.body.copyWith(height: 1.5)),
                  ]),
                ),
              )).toList()),
        ])),
      ),
      SliverToBoxAdapter(
        child: Band(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('What You Get'),
          const SizedBox(height: 12),
          Text('A complete water programme', style: AppText.pageTitle.copyWith(fontSize: wide ? 28 : 23)),
          const SizedBox(height: 26),
          Wrap(spacing: 18, runSpacing: 18, children: caps.map((c) => SizedBox(
                width: wide ? 360 : double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12)), child: Icon(c[0] as IconData, color: AppColors.blue700)),
                    const SizedBox(height: 16),
                    Text(c[1] as String, style: AppText.h3),
                    const SizedBox(height: 8),
                    Text(c[2] as String, style: AppText.body.copyWith(height: 1.5)),
                  ]),
                ),
              )).toList()),
        ])),
      ),
      SliverToBoxAdapter(child: _BottomCta(
        title: 'Not sure which solution fits?',
        sub: 'Tell us about your space and our team will recommend the right system.',
        primaryLabel: 'Request a Quotation',
        onPrimary: () => Navigator.of(context).pushNamed('/rfq'),
        secondaryLabel: 'Talk to Sales',
        onSecondary: () => Navigator.of(context).pushNamed('/contact'),
      )),
    ]);
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final String title, intro, cta;
  final List<String> points;
  final bool solid;
  final VoidCallback onTap;
  const _PathCard({required this.icon, required this.title, required this.intro, required this.points, required this.cta, required this.solid, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.blue700)),
          const SizedBox(width: 14),
          Text(title, style: AppText.h2.copyWith(fontSize: 20)),
        ]),
        const SizedBox(height: 14),
        Text(intro, style: AppText.bodyLg),
        const SizedBox(height: 16),
        ...points.map((p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check, size: 18, color: AppColors.blue600), const SizedBox(width: 10), Expanded(child: Text(p, style: AppText.body))]))),
        const SizedBox(height: 8),
        PwtButton(cta, variant: solid ? PwtBtn.primary : PwtBtn.outline, onPressed: onTap),
      ]),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final String title, sub, primaryLabel, secondaryLabel;
  final VoidCallback onPrimary, onSecondary;
  const _BottomCta({required this.title, required this.sub, required this.primaryLabel, required this.onPrimary, required this.secondaryLabel, required this.onSecondary});
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 720;
    return Band(child: Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.blue700, AppColors.blue600]), borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: wide ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
        Expanded(flex: wide ? 1 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: AppText.pageTitle.copyWith(color: Colors.white, fontSize: 23)),
          const SizedBox(height: 8),
          Text(sub, style: AppText.bodyLg.copyWith(color: Colors.white.withOpacity(.9))),
        ])),
        SizedBox(width: wide ? 20 : 0, height: wide ? 0 : 18),
        Wrap(spacing: 12, runSpacing: 12, children: [
          PwtButton(primaryLabel, variant: PwtBtn.outline, onPressed: onPrimary),
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
      ]),
    ));
  }
}
