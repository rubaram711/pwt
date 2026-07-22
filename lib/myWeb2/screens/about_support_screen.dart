import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/site_chrome.dart';
import '../widgets/common.dart';
import 'solutions_screen.dart' show PageHero;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;
    final values = [
      [Icons.water_drop, 'Purity first', 'Every system is engineered to deliver water you can taste the difference in — no compromises.'],
      [Icons.eco, 'Sustainable by design', 'Reusable filters and refillable systems that cut single-use plastic out of daily life.'],
      [Icons.handshake_outlined, 'Service that stays', 'Installation, maintenance and filter care handled for the life of your system.'],
    ];
    final stats = [
      ['10K+', 'Happy Customers'],
      ['15+', 'Years of Experience'],
      ['30+', 'Countries Served'],
      ['99%', 'Satisfaction Rate'],
    ];
    return StoreScaffold(active: '/about', slivers: [
      const SliverToBoxAdapter(
        child: PageHero(
          crumb: 'About Us',
          eyebrow: 'Our Story',
          title: 'On a mission to make pure water effortless.',
          lede: 'PWT was founded on a simple belief: everyone deserves clean, great-tasting water without the waste of single-use plastic. Today we serve homes and businesses across 30+ countries.',
        ),
      ),
      SliverToBoxAdapter(
        child: Band(child: Flex(
          direction: wide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: wide ? 1 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Eyebrow('Who We Are'),
              const SizedBox(height: 14),
              Text('From a single dispenser to a complete water programme.', style: AppText.pageTitle.copyWith(fontSize: wide ? 26 : 22)),
              const SizedBox(height: 14),
              Text('We design, install and maintain advanced purification systems — multi-stage filtration, reverse osmosis and connected monitoring — so our customers never think twice about the water they drink. From a family kitchen to a 200-site enterprise rollout, the promise is the same: purity you can taste, handled for you.',
                  style: AppText.bodyLg.copyWith(height: 1.7)),
            ])),
            SizedBox(width: wide ? 28 : 0, height: wide ? 0 : 24),
            Expanded(flex: wide ? 1 : 0, child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Image.asset('assets/images/sol-companies.png', height: 280, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 280, color: AppColors.soft)),
            )),
          ],
        )),
      ),
      SliverToBoxAdapter(
        child: Band(color: AppColors.soft, child: Wrap(alignment: WrapAlignment.spaceEvenly, runSpacing: 18, children: stats.map((s) => SizedBox(
              width: 160,
              child: Column(children: [
                Text(s[0], style: AppText.pageTitle.copyWith(color: AppColors.blue700, fontSize: 32)),
                const SizedBox(height: 4),
                Text(s[1], style: AppText.muted, textAlign: TextAlign.center),
              ]),
            )).toList())),
      ),
      SliverToBoxAdapter(
        child: Band(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('What We Value'),
          const SizedBox(height: 12),
          Text('The principles behind every system', style: AppText.pageTitle.copyWith(fontSize: wide ? 28 : 23)),
          const SizedBox(height: 26),
          Wrap(spacing: 18, runSpacing: 18, children: values.map((v) => SizedBox(
                width: wide ? 360 : double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12)), child: Icon(v[0] as IconData, color: AppColors.blue700)),
                    const SizedBox(height: 16),
                    Text(v[1] as String, style: AppText.h3),
                    const SizedBox(height: 8),
                    Text(v[2] as String, style: AppText.body.copyWith(height: 1.5)),
                  ]),
                ),
              )).toList()),
        ])),
      ),
    ]);
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;
    final cats = [
      [Icons.shopping_bag_outlined, 'Orders & Delivery', 'Track orders, delivery windows and installation scheduling.'],
      [Icons.build_outlined, 'Maintenance', 'Filter replacements, service visits and reschedules.'],
      [Icons.receipt_long_outlined, 'Billing', 'Invoices, rental payments and account statements.'],
      [Icons.water_drop_outlined, 'Products', 'Specs, warranty and how to choose the right system.'],
    ];
    final faqs = const [
      ['How do I track my order?', 'Open your dashboard and go to Orders — every order shows a live status and a tracking timeline.'],
      ['When is my next filter change?', 'Maintenance reminders appear in your dashboard and we email you ahead of every due date.'],
      ['How do I download an invoice?', 'Go to Invoices History in your dashboard and tap Download on any row.'],
      ['Can I change my rental plan?', 'Yes — contact your account manager or our support team and we will adjust your plan from the next billing cycle.'],
    ];
    return StoreScaffold(active: '/support', slivers: [
      const SliverToBoxAdapter(
        child: PageHero(
          crumb: 'Support',
          eyebrow: 'Help Center',
          title: 'How can we help?',
          lede: 'Answers to common questions, plus a direct line to our team whenever you need a human.',
        ),
      ),
      SliverToBoxAdapter(
        child: Band(child: Wrap(spacing: 18, runSpacing: 18, children: cats.map((c) => SizedBox(
              width: wide ? 270 : double.infinity,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(12)), child: Icon(c[0] as IconData, color: AppColors.blue700)),
                  const SizedBox(height: 14),
                  Text(c[1] as String, style: AppText.h3.copyWith(fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(c[2] as String, style: AppText.body.copyWith(height: 1.5)),
                ]),
              ),
            )).toList())),
      ),
      SliverToBoxAdapter(
        child: Band(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Popular questions', style: AppText.pageTitle.copyWith(fontSize: wide ? 26 : 22)),
          const SizedBox(height: 18),
          ...faqs.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f[0], style: AppText.h3.copyWith(fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(f[1], style: AppText.body.copyWith(height: 1.55, color: AppColors.ink600)),
                ]),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: wide ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [
              Expanded(flex: wide ? 1 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Still need help?', style: AppText.h2.copyWith(fontSize: 20)),
                const SizedBox(height: 6),
                Text('Our team responds within hours, every business day.', style: AppText.body.copyWith(color: AppColors.ink600)),
              ])),
              SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
              PwtButton('Contact Support', onPressed: () => Navigator.of(context).pushNamed('/contact')),
            ]),
          ),
        ])),
      ),
    ]);
  }
}
