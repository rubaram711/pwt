import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../state/app_state.dart';
import 'site_chrome.dart';

class DashNavEntry {
  final String id, label, route;
  final IconData icon;
  const DashNavEntry(this.id, this.label, this.route, this.icon);
}

const _companyNav = [
  DashNavEntry('devices', 'Machines', '/companyDashboard', Icons.grid_view_rounded),
  DashNavEntry('orders', 'Orders', '/companyOrders', Icons.inventory_2_outlined),
  DashNavEntry('maintenance', 'Maintenance', '/companyMaintenance', Icons.build_outlined),
  // Hidden for now — keep the route/screen intact, just not linked from the nav.
  // DashNavEntry('invoices', 'Invoices History', '/invoices', Icons.description_outlined),
  DashNavEntry('settings', 'Settings', '/settings', Icons.settings_outlined),
  DashNavEntry('profile', 'Profile', '/profile', Icons.person_outline),
];
const _individualNav = [
  DashNavEntry('devices', 'Machines', '/dashboard', Icons.grid_view_rounded),
  DashNavEntry('orders', 'Orders', '/orders', Icons.inventory_2_outlined),
  // Hidden for now — keep the route/screen intact, just not linked from the nav.
  // DashNavEntry('invoices', 'Invoices History', '/invoices', Icons.description_outlined),
  DashNavEntry('settings', 'Settings', '/settings', Icons.settings_outlined),
  DashNavEntry('profile', 'Profile', '/profile', Icons.person_outline),
];

class DashScaffold extends StatelessWidget {
  final String active;
  final bool isCompany;
  final Widget child;
  const DashScaffold({super.key, required this.active, required this.isCompany, required this.child});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 860;
    final nav = isCompany ? _companyNav : _individualNav;
    return Scaffold(
      backgroundColor: AppColors.dashBg,
      appBar: _DashHeader(isCompany: isCompany, showMenu: !wide),
      drawer: wide ? null : Drawer(width: 260, child: _Sidebar(active: active, nav: nav)),
      body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (wide) SizedBox(width: 260, child: _Sidebar(active: active, nav: nav)),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 28, wide ? 32 : 20, 60),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DashHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isCompany;
  final bool showMenu;
  const _DashHeader({required this.isCompany, required this.showMenu});

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final showLinks = MediaQuery.of(context).size.width > 1040;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 74,
      automaticallyImplyLeading: false,
      shape: const Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: showMenu ? 14 : 32),
            child: Row(children: [
              if (showMenu)
                Builder(builder: (c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                      onTap: () => Scaffold.of(c).openDrawer(),
                      child: const Icon(Icons.menu, color: AppColors.ink800, size: 24)),
                )),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
                child: Row(children: [
                  Image.asset('assets/images/full_logo_2.png',
                      height: 46,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.water_drop, color: AppColors.blue700, size: 30)),
                ]),
              ),
              if (showLinks)
                Expanded(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _hLink(context, 'Home', '/'),
                      _hLink(context, 'Shop', '/shop'),
                      _hLink(context, 'Solutions', '/solutions'),
                      _hLink(context, 'About Us', '/about'),
                      _hLink(context, 'Contact Us', '/contact'),
                    ]))
              else
                const Spacer(),
              // Hidden for now — will return later.
              // const LangSwitcher(),
              // const SizedBox(width: 18),
              _cartIcon(context),
              const SizedBox(width: 16),
              AccountAction(dashboardCompany: isCompany),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _hLink(BuildContext context, String label, String route) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink700)),
    ),
  );

  Widget _cartIcon(BuildContext context) => InkWell(
    onTap: () => Navigator.of(context).pushNamed('/cart'),
    child: Stack(clipBehavior: Clip.none, children: [
      const Icon(Icons.shopping_cart_outlined, size: 22, color: AppColors.ink800),
      Positioned(
        top: -7,
        right: -8,
        child: AnimatedBuilder(
          animation: AppState.instance,
          builder: (_, __) {
            final n = AppState.instance.cartCount;
            if (n == 0) return const SizedBox.shrink();
            return Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                  color: AppColors.blue600,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2)),
              child: Text('$n',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1)),
            );
          },
        ),
      ),
    ]),
  );
}

class _Sidebar extends StatelessWidget {
  final String active;
  final List<DashNavEntry> nav;
  const _Sidebar({required this.active, required this.nav});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 22, 14, 16),
            child: Builder(builder: (context) {
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                ...nav.map((n) => _navItem(context, n.icon, n.label, active == n.id, () {
                  final s = Scaffold.maybeOf(context);
                  if (s?.isDrawerOpen ?? false) s!.closeDrawer();
                  if (active != n.id) Navigator.of(context).pushReplacementNamed(n.route);
                })),
                const SizedBox(height: 6),
                _navItem(context, Icons.logout, 'Log Out', false, () async {
                  await AppState.instance.signOut();
                  if (context.mounted)
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
                }, isLogout: true),
              ]);
            }),
          ),
        ),
        Image.asset('assets/images/splash.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
      ]),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool on, VoidCallback onTap,
      {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: on ? AppColors.blue700 : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(children: [
              Icon(icon, size: 20, color: on ? Colors.white : AppColors.ink400),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                      color: on ? Colors.white : (isLogout ? AppColors.ink600 : AppColors.ink700))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Dashboard primitives
// ============================================================

class DashCrumb extends StatelessWidget {
  final List<String> trail;
  final List<String?> routes;
  const DashCrumb(this.trail, {super.key, this.routes = const []});
  @override
  Widget build(BuildContext context) {
    final kids = <Widget>[];
    for (var i = 0; i < trail.length; i++) {
      final here = i == trail.length - 1;
      final route = i < routes.length ? routes[i] : null;
      kids.add(here
          ? Text(trail[i],
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink800))
          : InkWell(
          onTap: route == null ? null : () => Navigator.of(context).pushReplacementNamed(route),
          child: Text(trail[i],
              style: const TextStyle(fontSize: 13, color: AppColors.ink500))));
      if (!here)
        kids.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Text('›', style: TextStyle(fontSize: 13, color: AppColors.ink400))));
    }
    return Row(children: kids);
  }
}

class PageHead extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const PageHead({super.key, required this.title, this.subtitle, this.action});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 22),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.ink900,
                      height: 1.05)),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(subtitle!, style: const TextStyle(fontSize: 14, color: AppColors.ink500))
              ],
            ])),
        if (action != null) ...[const SizedBox(width: 18), action!],
      ]),
    );
  }
}

class NewOrderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const NewOrderButton({super.key, required this.label, this.icon = Icons.add, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: AppColors.blue700.withOpacity(.28), blurRadius: 24, offset: const Offset(0, 10))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 9),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color border;
  final Color background;
  const DCard(
      {super.key,
        required this.child,
        this.padding = const EdgeInsets.all(22),
        this.border = AppColors.line,
        this.background = Colors.white});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [BoxShadow(color: Color(0x0A0F1E50), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class DCardHead extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const DCardHead(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink900)),
        if (trailing != null) ...[const Spacer(), trailing!],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KpiCard — FIX: replaced Spacer() with SizedBox + mainAxisSize: min
// Spacer() inside a Column inside SingleChildScrollView = h=Infinity crash.
// ─────────────────────────────────────────────────────────────────────────────
class KpiCard extends StatelessWidget {
  final String label, value, sub;
  final double numSize;
  const KpiCard(
      {super.key, required this.label, required this.value, required this.sub, this.numSize = 40});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [BoxShadow(color: Color(0x0A0F1E50), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // FIX: never unbounded
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink500)),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: numSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.ink900,
                  height: 1)),
          const SizedBox(height: 8), // FIX: was Spacer()
          Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.ink500)),
        ],
      ),
    );
  }
}

/// Responsive KPI grid using Wrap — safe inside any scroll context.
class KpiRow extends StatelessWidget {
  final List<Widget> cards;
  const KpiRow({super.key, required this.cards});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth <= 480 ? 1 : c.maxWidth <= 1100 ? 2 : 4;
      const gap = 18.0;
      final tileW = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards.map((card) => SizedBox(width: tileW, child: card)).toList());
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KpiFeatureCard — FIX: replaced Spacer() with SizedBox + mainAxisSize: min
// ─────────────────────────────────────────────────────────────────────────────
class KpiFeatureCard extends StatelessWidget {
  final String label, value;
  final String? link;
  final String? sub;
  final String? image;
  final VoidCallback? onLink;
  const KpiFeatureCard(
      {super.key,
        required this.label,
        required this.value,
        this.link,
        this.sub,
        this.image,
        this.onLink});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF1D4ED8)],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x421D4ED8), blurRadius: 36, offset: Offset(0, 16))
        ],
      ),
      child: Stack(children: [
        if (image != null)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.55],
                ).createShader(r),
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(image!,
                      fit: BoxFit.cover, alignment: Alignment.centerRight, height: double.infinity),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // FIX: never unbounded
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: Colors.white,
                      height: 1)),
              const SizedBox(height: 12), // FIX: was Spacer()
              if (link != null)
                InkWell(
                  onTap: onLink,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(link!,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                  ]),
                )
              else if (sub != null)
                Text(sub!,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.8))),
            ],
          ),
        ),
      ]),
    );
  }
}

class StBadge extends StatelessWidget {
  final String text;
  const StBadge(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = _color(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(color: c.$1, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: c.$2, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.$2)),
      ]),
    );
  }

  static (Color, Color) _color(String t) {
    final s = t.toLowerCase();
    if (s.contains('quotation') || s.contains('quote'))
      return (const Color(0xFFF1EBFF), const Color(0xFF6D28D9));
    if (s.contains('cancel')) return (const Color(0xFFEEF2F9), AppColors.ink500);
    if (s.contains('await') || s.contains('pending') || s.contains('process') || s.contains('ordered'))
      return (const Color(0xFFFFF3DF), const Color(0xFFB45309));
    if (s.contains('agreed') ||
        s.contains('delivered') ||
        s.contains('paid') ||
        s.contains('purchas') ||
        s.contains('complete')) return (const Color(0xFFE7F7EF), AppColors.green600);
    return (const Color(0xFFE6EFFF), AppColors.blue700);
  }
}

enum DBtnKind { primary, outline, ghost, danger }

class DBtn extends StatelessWidget {
  final String label;
  final DBtnKind kind;
  final IconData? icon;
  final bool small;
  final bool fullWidth;
  final VoidCallback? onTap;
  const DBtn(this.label,
      {super.key,
        this.kind = DBtnKind.primary,
        this.icon,
        this.small = false,
        this.fullWidth = false,
        this.onTap});

  @override
  Widget build(BuildContext context) {
    final pad = small
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 11);
    final fs = small ? 12.5 : 13.5;
    late final BoxDecoration deco;
    late final Color fg;
    switch (kind) {
      case DBtnKind.primary:
        deco = BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                  color: AppColors.blue700.withOpacity(.26), blurRadius: 20, offset: const Offset(0, 8))
            ]);
        fg = Colors.white;
        break;
      case DBtnKind.outline:
        deco = BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.line, width: 1.5),
            borderRadius: BorderRadius.circular(11));
        fg = AppColors.ink800;
        break;
      case DBtnKind.ghost:
        deco = BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(11));
        fg = AppColors.blue700;
        break;
      case DBtnKind.danger:
        deco = BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF3C9C9), width: 1.5),
            borderRadius: BorderRadius.circular(11));
        fg = const Color(0xFFDD3333);
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: pad,
        decoration: deco,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: fs + 2, color: fg), const SizedBox(width: 8)],
            Text(label, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600, color: fg)),
          ],
        ),
      ),
    );
  }
}

class ProdCellD extends StatelessWidget {
  final String image, name, sub;
  const ProdCellD({super.key, required this.image, required this.name, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 44, height: 44,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(11)),
          gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 0.7,
              colors: [Color(0xFFF6F9FF), Color(0xFFE6EEF9)]),
        ),
        padding: const EdgeInsets.all(6),
        child: Image.asset(image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(sub,
                style: const TextStyle(fontSize: 12, color: AppColors.ink500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ]);
  }
}

class TlStep {
  final String title, sub;
  final bool done, pending;
  const TlStep(this.title, this.sub, {this.done = false, this.pending = false});
}

class DashTimeline extends StatelessWidget {
  final List<TlStep> steps;
  const DashTimeline(this.steps, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final dotColor =
        s.done ? AppColors.green500 : (s.pending ? AppColors.ink300 : AppColors.blue700);
        final fill = s.done ? AppColors.green500 : Colors.white;
        // IntrinsicHeight is safe here: the outer Column has mainAxisSize.min
        // so the parent is bounded. IntrinsicHeight is only needed to stretch
        // the connector line to match the text height.
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 16, height: 16,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 3)),
              ),
              if (i < steps.length - 1) Expanded(child: Container(width: 2, color: AppColors.line)),
            ]),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink900)),
                    const SizedBox(height: 2),
                    Text(s.sub,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.ink500)),
                  ],
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }
}