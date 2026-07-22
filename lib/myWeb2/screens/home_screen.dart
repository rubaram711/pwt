import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/site_chrome.dart';
import '../widgets/common.dart';
import '../../Models/Products/products_model.dart';
import '../../Backend/Products/get_filtered_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreScaffold(
      active: '/',
      slivers: [
        SliverToBoxAdapter(child: _Hero()),
        SliverToBoxAdapter(child: _Solutions()),
        SliverToBoxAdapter(child: _TopProducts()),
        SliverToBoxAdapter(child: _Process()),
        SliverToBoxAdapter(child: _Benefits()),
        SliverToBoxAdapter(child: _CtaBanner()),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return Stack(children: [
      // ── Background image fills entire Stack including behind stats bar ──
      Positioned.fill(
        child: Image.asset('assets/images/lake-mountain.jpeg', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.blue50)),
      ),
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.white.withOpacity(.97), Colors.white.withOpacity(wide ? .35 : .88)],
            ),
          ),
        ),
      ),
      // ── Content column (hero text/image + stats bar) ──
      Column(children: [
        Band(
          padding: EdgeInsets.fromLTRB(28, wide ? 72 : 56, 28, wide ? 52 : 40),
          child: Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: wide ? 5 : 0,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.water_drop, color: AppColors.blue600, size: 16),
                    const SizedBox(width: 6),
                    const Eyebrow('Pure Water. Pure Life.'),
                  ]),
                  const SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: AppText.headline(wide ? 52 : 38),
                      children: const [
                        TextSpan(text: 'Water that actually '),
                        TextSpan(text: 'tastes', style: TextStyle(color: AppColors.blue600)),
                        TextSpan(text: '\nlike water.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Advanced water purification solutions for a healthier, better everyday. From home to enterprise, we deliver purity you can taste.',
                      style: AppText.bodyLg.copyWith(height: 1.6), softWrap: true),
                  const SizedBox(height: 26),
                  Wrap(spacing: 15, runSpacing: 12, children: [
                    HomePwtButton('Explore Solutions', onPressed: () => Navigator.of(context).pushNamed('/solutions')),
                    HomePwtButton('Watch Video', variant: PwtBtn.outline, icon: Icons.play_arrow_rounded, onPressed: () {}),
                  ]),
                  const SizedBox(height: 30),
                  Wrap(spacing: 22, runSpacing: 16, children: const [
                    _FeaturePill(Icons.water_drop, 'High Quality\nFiltration', AppColors.blue600),
                    _FeaturePill(Icons.settings_outlined, 'Easy\nMaintenance', AppColors.ink400),
                    _FeaturePill(Icons.eco_outlined, 'Eco\nFriendly', AppColors.green600),
                    _FeaturePill(Icons.groups_2_outlined, 'Trusted by\nThousands', AppColors.purple),
                  ]),
                ]),
              ),
              if (wide) const SizedBox(width: 20),
              Expanded(
                flex: wide ? 6 : 0,
                child: Padding(
                  padding: EdgeInsets.only(top: wide ? 0 : 30),
                  child: Image.asset('assets/images/podium-hero.png', fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(height: 420)),
                ),
              ),
            ],
          ),
        ),
        // ── Stats bar — inside the Stack so background image is behind it ──
        Padding(
          padding: const EdgeInsets.fromLTRB(110, 0, 110, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadow.lg,
              border: Border.all(color: AppColors.line),
            ),
            child: wide
                ? IntrinsicHeight(
                    child: Row(children: [
                      for (int i = 0; i < _stats.length; i++) ...[
                        Expanded(child: _statItem(_stats[i][0], _stats[i][1])),
                        if (i < _stats.length - 1)
                          Container(width: 1, color: const Color(0xFFE2E8F0)),
                      ],
                    ]),
                  )
                : Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runSpacing: 22,
                    children: _stats.map((s) => SizedBox(width: 150, child: _statItem(s[0], s[1]))).toList(),
                  ),
          ),
        ),
      ]),
    ]);
  }

  static const _stats = [
    ['10K+', 'Happy Customers'],
    ['15+', 'Years of Experience'],
    ['30+', 'Countries Served'],
    ['99%', 'Satisfaction Rate'],
  ];

  Widget _statItem(String value, String label) => Column(children: [
        Text(value, style: AppText.pageTitle.copyWith(color: AppColors.blue700, fontSize: 32)),
        const SizedBox(height: 5),
        Text(label, style: AppText.muted),
      ]);
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeaturePill(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 10),
      Text(label, style: AppText.label.copyWith(height: 1.25)),
    ]);
  }
}


class _Solutions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;
    return Band(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Eyebrow('Solutions for Everyone'),
        const SizedBox(height: 14),
        Text('Choose What Suits You Best', style: AppText.pageTitle.copyWith(fontSize: wide ? 30 : 24), textAlign: TextAlign.center),
        const SizedBox(height: 34),
        Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(flex: wide ? 1 : 0, child: _SolCard(
                icon: Icons.person_outline,
                title: 'For Individuals',
                intro: 'Buy or rent premium water purification systems for your home.',
                points: const ['Instant purchase or flexible rental options', 'Bulk orders', 'Fast delivery & installation'],
                image: 'assets/images/sol-individuals.png',
                ctaLabel: 'Shop Now',
                onTap: () => Navigator.of(context).pushNamed('/shop'),
                solid: true,
              )),
              SizedBox(width: wide ? 24 : 0, height: wide ? 0 : 24),
              Expanded(flex: wide ? 1 : 0, child: _SolCard(
                icon: Icons.apartment,
                title: 'For Companies',
                intro: 'Get a customised quotation tailored to your business needs.',
                points: const ['Personalised pricing', 'Bulk orders', 'Dedicated account manager', 'Dedicated support'],
                image: 'assets/images/sol-companies.png',
                ctaLabel: 'Request a Quotation',
                onTap: () => Navigator.of(context).pushNamed('/rfq'),
                solid: false,
              )),
            ],
          ),

      ]),
    );
  }
}

class _SolCard extends StatelessWidget {
  final IconData icon;
  final String title, intro, image, ctaLabel;
  final List<String> points;
  final VoidCallback onTap;
  final bool solid;
  const _SolCard({required this.icon, required this.title,
    required this.intro, required this.points, required this.image, required this.ctaLabel, required this.onTap, required this.solid});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;


    final content = Container(
      color: AppColors.blue50,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Icon + Title ──
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.blue100, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.blue700),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppText.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 14),
          Text(intro, style: AppText.bodyLg),
          const SizedBox(height: 16),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check, size: 18, color: AppColors.blue600),
              const SizedBox(width: 10),
              Expanded(child: Text(p, style: AppText.body)),
            ]),
          )),
          const SizedBox(height: 16),
          // ── Button ──
          SizedBox(
            child: Material(
              color: solid ? AppColors.blue700 : Colors.white,
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    // ── outline = أزرق ──
                    border: Border.all(
                      color: solid ? AppColors.blue700 : AppColors.blue700,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    ctaLabel,
                    style: AppText.label.copyWith(
                      color: solid ? Colors.white : AppColors.blue700,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );

    final photo = Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppColors.soft),
    );

    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        child: wide
            ? IntrinsicHeight(child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: content),
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppRadius.xl),
                    bottomRight: Radius.circular(AppRadius.xl),
                  ),
                  child: SizedBox.expand(
                    child: photo,
                  ),
                ),
              ),
            ],
          ))

        // ── Column على الموبايل: محتوى فوق، صورة تحت ──
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          content,
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
              child: photo,
            ),
          ),
        ]),
    );
  }
}

class _TopProducts extends StatefulWidget {
  @override
  State<_TopProducts> createState() => _TopProductsState();
}

class _TopProductsState extends State<_TopProducts> {
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getFilteredProducts(tagLabel: 'best_seller', perPage: 4).then((result) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (result.success && result.data != null) {
          _products = result.data!.items;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;
    return Band(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Eyebrow('Best Sellers'),
            const SizedBox(height: 10),
            Text('Our Top Products', style: AppText.pageTitle.copyWith(fontSize: wide ? 28 : 23)),
          ]),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/shop'),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('View All Products', style: AppText.label.copyWith(color: AppColors.blue700)),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.blue700),
            ]),
          ),
        ]),
        const SizedBox(height: 22),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_products.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Center(child: Text('No products found.', style: AppText.muted)))
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: wide ? 4 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.82,
            children: _products.map((p) => InkWell(
              onTap: () => Navigator.of(context).pushNamed('/product', arguments: p),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: p.primaryImageUrl != null
                            ? Image.network(p.primaryImageUrl!, fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.ink300))
                            : const Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.ink300),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name ?? '', style: AppText.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(p.shortDescription ?? '', style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (p.startingPrice != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          'From ${p.startingPrice!.currency} ${p.startingPrice!.amount}/${p.startingPrice!.period ?? 'mo'}',
                          style: AppText.muted.copyWith(color: AppColors.blue700, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ]),
                  ),
                ]),
              ),
            )).toList(),
          ),
      ]),
    );
  }
}

class _Process extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      ['1', 'Source',
        'We begin with carefully selected water sources, monitoring for optimal quality and mineral content.',
        Icons.water_drop],
      ['2', 'Multi-Stage Filtration',
        'Advanced filtration removes impurities, sediments and contaminants through 5 purification stages.',
        Icons.grid_on],
      ['3', 'Purified Perfection',
        'Clean, safe and great-tasting water delivered to you at home or at your business premises.',
        Icons.filter_alt_outlined],
      ['4', 'Delivered to You',
        'Enjoy pure water at home or at the office, with regular maintenance and filter replacements included.',
        Icons.home_outlined],
    ];
    final wide = MediaQuery.of(context).size.width > 820;

    return Band(
      child: Column(children: [
        const Eyebrow('Our Process'),
        const SizedBox(height: 14),
        Text(
          'How Our Solution Works',
          style: AppText.pageTitle.copyWith(fontSize: wide ? 34 : 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        wide
        // ── Wide: 4 أعمدة أفقية ──
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── دائرة الأيقونة ──
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.blue50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(steps[i][3] as IconData, color: AppColors.blue700, size: 30),
                    ),
                    const SizedBox(width: 14),
                    // ── رقم + عنوان + نص ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // رقم الـ step + العنوان
                          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.blue700,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  steps[i][0] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                steps[i][1] as String,
                                style: AppText.h3.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          Text(
                            steps[i][2] as String,
                            style: AppText.body.copyWith(height: 1.6, color: AppColors.ink500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── السهم المنقط بين الـ steps ──
              if (i < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 70, left: 8, right: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    _DashArrow(),
                  ]),
                ),
            ],
          ],
        )

        // ── موبايل: عمودي ──
            : Column(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.blue50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(steps[i][3] as IconData, color: AppColors.blue700, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                          child: Center(child: Text(steps[i][0] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                        ),
                        const SizedBox(width: 6),
                        Flexible(child: Text(steps[i][1] as String,
                            style: AppText.h3.copyWith(fontSize: 15, fontWeight: FontWeight.w800))),
                      ]),
                      const SizedBox(height: 8),
                      Text(steps[i][2] as String,
                          style: AppText.body.copyWith(height: 1.6, color: AppColors.ink500)),
                    ]),
                  ),
                ],
              ),
              if (i < steps.length - 1) const SizedBox(height: 24),
            ],
          ],
        ),
      ]),
    );
  }
}

// ── السهم المنقط الأفقي ──
class _DashArrow extends StatelessWidget {
  const _DashArrow();
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...List.generate(3, (_) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 1.5, color: AppColors.blue200),
        const SizedBox(width: 3),
      ])),
      const Icon(Icons.arrow_forward, size: 20, color: AppColors.blue200),
    ]);
  }
}

class _StepItem extends StatelessWidget {
  final List<dynamic> step;
  const _StepItem({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── دائرة الأيقونة الكبيرة ──
      Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.blue50,
          shape: BoxShape.circle,
        ),
        child: Icon(step[3] as IconData, color: AppColors.blue700, size: 30),
      ),
      const SizedBox(height: 16),

      // ── رقم الـ step + العنوان في صف ──
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // دائرة الرقم
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.blue700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step[0] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            step[1] as String,
            style: AppText.h3.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ]),
      const SizedBox(height: 10),

      // ── النص ──
      Text(
        step[2] as String,
        style: AppText.body.copyWith(height: 1.6, color: AppColors.ink500),
      ),
    ]);
  }
}

class _Benefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 820;

    // ── لون مختلف لكل benefit ──
    final bens = [
      [Icons.water_drop,      'Better Taste',      'Remove chlorine and impurities that affect flavour and smell of your drinking water.',           const Color(0xFFEEF2FF), AppColors.blue700],
      [Icons.favorite_border, 'Better Health',     'Reduce exposure to harmful substances and volatile chemicals that impact health.',               const Color(0xFFFFF0F0), const Color(0xFFE05555)],
      [Icons.savings_outlined,'Cost Effective',    'Economical water purification systems that reduce plastic waste and bottled water costs.',       const Color(0xFFF0F7FF), const Color(0xFF5B9BD5)],
      [Icons.eco_outlined,             'Better Planet',     'Eco-friendly filters that reduce plastic waste and support a sustainable future.',              const Color(0xFFF0FBF4), const Color(0xFF3DAA6A)],
      [Icons.settings_outlined,        'Easy Maintenance',  'Simple filter changes and professional maintenance for worry-free pure water.',                  const Color(0xFFF5F5FF), const Color(0xFF7B7FCC)],
      [Icons.verified_outlined,'Reliable Quality', 'Tested and certified systems that deliver consistent, high-quality water every time.',          const Color(0xFFF0F7FF), const Color(0xFF5B9BD5)],
    ];

    return Band(
      child: Container(
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          // ── الصورة 1: خلفية بيضاء فاتحة مع border ──
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Eyebrow عادي بدون خلفية ──
          const Eyebrow('Why PWT'),
          const SizedBox(height: 10),
          Text(
            'The Benefits You Can Feel',
            style: AppText.pageTitle.copyWith(
              color: AppColors.ink900,
              fontSize: wide ? 28 : 23,
            ),
          ),
          const SizedBox(height: 32),

          // ── 6 أعمدة أفقية على wide ──
          wide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bens.map((b) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _BenefitItem(
                  icon: b[0] as IconData,
                  title: b[1] as String,
                  desc: b[2] as String,
                  iconBg: b[3] as Color,
                  iconColor: b[4] as Color,
                ),
              ),
            )).toList(),
          )
          // ── موبايل: 2 أعمدة ──
              : Wrap(
            spacing: 16,
            runSpacing: 24,
            children: bens.map((b) => SizedBox(
              width: (MediaQuery.of(context).size.width - 100) / 2,
              child: _BenefitItem(
                icon: b[0] as IconData,
                title: b[1] as String,
                desc: b[2] as String,
                iconBg: b[3] as Color,
                iconColor: b[4] as Color,
              ),
            )).toList(),
          ),
        ]),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color iconBg;
  final Color iconColor;
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── أيقونة مربعة بخلفية ملونة فاتحة ──
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      const SizedBox(height: 14),
      Text(
        title,
        style: AppText.h3.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.ink900,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        desc,
        style: AppText.body.copyWith(
          color: AppColors.ink500,
          height: 1.6,
          fontSize: 13.5,
        ),
      ),
    ]);
  }
}

class _CtaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 720;

    return Band(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          height: wide ? 180 : null,
          decoration: BoxDecoration(
            color: AppColors.blue50,
            border: Border.all(color: const Color(0xFFBFD7F7)),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // ── صورة الـ water splash تملأ الجانب الأيسر بالكامل ──
              if (wide)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 320,
                  child: Image.asset(
                    'assets/images/water-splash.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),

              // ── gradient فوق الصورة لضمان قراءة النص ──
              // if (wide)
              //   Positioned(
              //     left: 0,
              //     top: 0,
              //     bottom: 0,
              //     width: 320,
              //     child: DecoratedBox(
              //       decoration: BoxDecoration(
              //         gradient: LinearGradient(
              //           begin: Alignment.centerRight,
              //           end: Alignment.centerLeft,
              //           colors: [
              //             AppColors.blue50,
              //             AppColors.blue50.withOpacity(0.0),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),

              // ── المحتوى فوق الصورة ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                child: wide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // مسافة لتجاوز الصورة جزئياً
                    const SizedBox(width: 70),
                    // ── نص ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ready for pure water?',
                            style: AppText.pageTitle.copyWith(
                              color: AppColors.ink900,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Join thousands of happy customers across the UK. Get started today.',
                            style: AppText.body.copyWith(color: AppColors.ink500,fontSize: 16,),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    // ── أزرار ──
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      _pill('Shop Now', solid: true,
                          onTap: () => Navigator.of(context).pushNamed('/shop')),
                      const SizedBox(width: 12),
                      _pill('Contact Us', solid: false,
                          onTap: () => Navigator.of(context).pushNamed('/contact')),
                    ]),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for pure water?',
                      style: AppText.pageTitle.copyWith(
                        color: AppColors.ink900,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join thousands of happy customers across the UK. Get started today.',
                      style: AppText.body.copyWith(color: AppColors.ink500),
                    ),
                    const SizedBox(height: 20),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      _pill('Shop Now', solid: true,
                          onTap: () => Navigator.of(context).pushNamed('/shop')),
                      _pill('Contact Us', solid: false,
                          onTap: () => Navigator.of(context).pushNamed('/contact')),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, {required bool solid, required VoidCallback onTap}) {
    return Material(
      color: solid ? AppColors.blue700 : Colors.white,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: AppColors.blue700 ,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: solid ? Colors.white : AppColors.blue700,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}