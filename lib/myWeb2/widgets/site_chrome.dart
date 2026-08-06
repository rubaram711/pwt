// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../../myApp/core/embedded_images.dart';

/// The AED dirham symbol — the same embedded glyph myApp pairs with
/// numerals, used here instead of a currency code or symbol string.
class Dirham extends StatelessWidget {
  const Dirham({super.key, this.size = 12, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink900;
    return SvgPicture.memory(
      EmbeddedImages.dirham,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}

/// Money formatter: 1,536 or 1,536.50 — pair with `Dirham` for display (no
/// currency symbol baked in). Mirrors myApp's `_fmt`: whole numbers stay
/// unrounded integers, fractional amounts keep 2 decimal places rather than
/// being rounded away.
String money(num n) {
  final s = n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// A dirham glyph next to "1,536" — mirrors myApp's PriceText/_money helpers.
Widget moneyText(num v, TextStyle? style, {double symbolSize = 12, String prefix = '', String suffix = ''}) {
  final color = style?.color ?? AppColors.ink900;
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      if (prefix.isNotEmpty) Text(prefix, style: style),
      Dirham(size: symbolSize, color: color),
      const SizedBox(width: 4),
      Text('${money(v)}$suffix', style: style),
    ],
  );
}

const _storeLinks = [
  ['Home', '/'],
  ['Shop', '/shop'],
  ['Solutions', '/solutions'],
  ['About Us', '/about'],
  ['Contact Us', '/contact'],
];

/// Top storefront navbar (logo · links · search/cart/account · Sign In).
class SiteHeader extends StatelessWidget implements PreferredSizeWidget {
  final String active; // route name
  final bool showLeadingMenu;
  const SiteHeader({super.key, this.active = '/', this.showLeadingMenu = false});

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 78,
      shape: const Border(bottom: BorderSide(color: AppColors.line)),
      titleSpacing: showLeadingMenu ? 4 : 24,
      automaticallyImplyLeading: false,
      leading: showLeadingMenu ? Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu, color: AppColors.ink800), onPressed: () => Scaffold.of(c).openDrawer())) : null,
      title: Row(children: [
        // ── Left: Logo ───────────────────────────────────────────
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
              child: Image.asset(
                'assets/images/full_logo_2.png',
                height: 52,
                errorBuilder: (_, __, ___) => Text('PWT', style: AppText.h3.copyWith(fontSize: 25, letterSpacing: 1.0, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
        // ── Centre: Nav links (wide only) ────────────────────────
        if (wide)
          Row(mainAxisSize: MainAxisSize.min, children: [
            ..._storeLinks.map((l) => _NavLink(label: l[0], route: l[1], active: active == l[1])),
          ]),
        // ── Right: Actions ───────────────────────────────────────
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              // Hidden for now — will return later.
              // const LangSwitcher(),
              // const SizedBox(width: 16),
              if (!(AppState.instance.user?.isCompany ?? false))
                Stack(clipBehavior: Clip.none, children: [
                  _icon(context, Icons.shopping_cart_outlined, '/cart'),
                  Positioned(
                    right: 4,
                    top: 2,
                    child: AnimatedBuilder(
                      animation: AppState.instance,
                      builder: (_, __) {
                        final n = AppState.instance.cartCount;
                        if (n == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text('$n', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800, height: 1)),
                        );
                      },
                    ),
                  ),
                ]),
              const SizedBox(width: 14),
              const AccountAction(),
              const SizedBox(width: 6),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _icon(BuildContext context, IconData ic, String? route) => IconButton(
        onPressed: route == null ? () {} : () => Navigator.of(context).pushNamed(route),
        icon: Icon(ic, color: AppColors.ink800, size: 22),
        splashRadius: 22,
      );
}

class _NavLink extends StatelessWidget {
  final String label;
  final String route;
  final bool active;
  const _NavLink({required this.label, required this.route, required this.active});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: active
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.blue700, width: 3)),
              )
            : null,
        alignment: Alignment.center,
        child: Text(
          label,
          softWrap: false,
          style: AppText.body.copyWith(
            fontSize: 15.5,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.blue700 : AppColors.ink700,
          ),
        ),
      ),
    );
  }
}

/// Language switcher (globe + chevron) → English / العربية menu.
/// Mirrors the .snav language popover; selection persists via AppState.
class LangSwitcher extends StatelessWidget {
  const LangSwitcher({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (_, __) {
        final cur = AppState.instance.lang;
        return PopupMenuButton<String>(
          tooltip: 'Language',
          offset: const Offset(0, 42),
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE9EDF4))),
          onSelected: (v) => AppState.instance.setLang(v),
          itemBuilder: (_) => [
            _item('en', 'English', cur),
            _item('ar', 'العربية', cur),
          ],
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.language_outlined, size: 22, color: AppColors.ink800),
            SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.ink400),
          ]),
        );
      },
    );
  }

  PopupMenuItem<String> _item(String code, String label, String cur) => PopupMenuItem<String>(
        value: code,
        height: 40,
        child: Row(children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink800)),
          if (code == cur) ...[const Spacer(), const Icon(Icons.check, size: 16, color: AppColors.blue700)],
        ]),
      );
}

/// Right-side account control: a solid "Login" button when logged out, or a
/// profile dropdown (avatar · name ▾ → Machines / Orders / Invoices / Settings /
/// Profile / Log out) when logged in. Mirrors site-nav.js buildRight().
class AccountAction extends StatelessWidget {
  /// When set (on dashboard headers), a signed-out visitor still sees the
  /// profile dropdown using a demo persona — mirrors dash-shell.js, which
  /// guarantees a logged-in identity. `true` = company, `false` = individual.
  /// Left null on storefront headers, where signed-out shows a Login button.
  final bool? dashboardCompany;
  const AccountAction({super.key, this.dashboardCompany});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (_, __) {
        final u = AppState.instance.user;
        if (u == null && dashboardCompany == null) {
          return ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              textStyle: AppText.label.copyWith(fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
            child: const Text('Login'),
          );
        }
        final isCo = u?.isCompany ?? dashboardCompany!;
        final name = u != null
            ? (isCo ? ((u.companyName?.isEmpty ?? true) ? (u.name ?? '') : u.companyName!) : (u.name ?? ''))
            : (isCo ? 'Globex Facilities' : 'Sarah Johnson');
        final initials = u?.initials ?? (isCo ? 'GF' : 'SJ');
        final email = u?.email ?? '';
        return PopupMenuButton<String>(
          tooltip: 'Account',
          offset: const Offset(0, 50),
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE9EDF4))),
          constraints: const BoxConstraints(minWidth: 230),
          onSelected: (v) async {
            if (v == 'logout') {
              await AppState.instance.signOut();
              if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
            } else {
              Navigator.of(context).pushNamed(v);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.blue100, child: Text(initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.blue800))),
                const SizedBox(width: 11),
                Flexible(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink900), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (email.isNotEmpty) Text(email, style: const TextStyle(fontSize: 12, color: AppColors.ink400), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
              ]),
            ),
            const PopupMenuDivider(),
            _menuItem(isCo ? '/companyDashboard' : '/dashboard', Icons.grid_view_rounded, 'Machines'),
            _menuItem(isCo ? '/companyOrders' : '/orders', Icons.inventory_2_outlined, 'Orders'),
            // Hidden for now — keep the route/screen intact, just not linked from the menu.
            // _menuItem('/invoices', Icons.description_outlined, 'Invoices History'),
            _menuItem('/settings', Icons.settings_outlined, 'Settings'),
            _menuItem('/profile', Icons.person_outline, 'Profile'),
            _menuItem('logout', Icons.logout, 'Log out', danger: true),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB8D3FF), Color(0xFF82A8F0)])),
                child: Text(initials, style: const TextStyle(color: Color(0xFF16357A), fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              if (MediaQuery.of(context).size.width > 560) ...[
                const SizedBox(width: 9),
                ConstrainedBox(constraints: const BoxConstraints(maxWidth: 130), child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink900))),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.ink400),
              ],
            ]),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.ink700;
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(children: [
        Icon(icon, size: 17, color: danger ? AppColors.danger : AppColors.ink400),
        const SizedBox(width: 11),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }
}

/// WhatsApp circular FAB — number sourced from AppState (cached from public settings API).
class WhatsAppFab extends StatefulWidget {
  const WhatsAppFab({super.key});
  @override
  State<WhatsAppFab> createState() => _WhatsAppFabState();
}

class _WhatsAppFabState extends State<WhatsAppFab> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _open() {
    html.window.open('https://web.whatsapp.com/send?phone=971556539575', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _open,
      backgroundColor: const Color(0xFF25D366),
      shape: const CircleBorder(),
      elevation: 6,
      child: SvgPicture.string(_kWaSvg, width: 26, height: 26),
    );
  }
}

const _kWaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
</svg>
''';

/// Shared footer for storefront pages.
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 760;
    final cols = [
      ['SHOP', ['Water Dispensers', 'Countertop Systems', 'Reverse Osmosis', 'Filters & Cartridges'], '/shop'],
      ['SOLUTIONS', ['For Home', 'For Office', 'For Business', 'Industrial Solutions'], '/solutions'],
      ['COMPANY', ['About Us', 'Careers', 'Blog', 'News'], '/about'],
      ['SUPPORT', ['Help Center', 'Maintenance', 'Returns', 'Warranty'], '/support'],
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D2057), // داكن يسار
            Color(0xFF1B3A9E), // أزرق يمين
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(48, 56, 48, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── الصف الرئيسي ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo + description ──
                  SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/full_logo_2.png',
                          height: 44,
                          color: Colors.white,
                          errorBuilder: (_, __, ___) => const Text('PWT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                letterSpacing: 1.4,
                              )),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Advanced water purification solutions for a healthier, better everyday. Pure Water. Pure Life.',
                          style: AppText.body.copyWith(
                            color: const Color(0xFFB0BDD8),
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── بدل Spacer، استخدم Expanded للأعمدة ──
                  if (wide)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ← توزيع متساوي
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cols.map((c) => SizedBox(
                          width: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c[0] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ...(c[1] as List).map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pushNamed(c[2] as String),
                                  child: Text(
                                    t as String,
                                    style: AppText.body.copyWith(
                                      color: const Color(0xFFB0BDD8),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 48),
              const Divider(color: Color(0xFF2A3F7E), height: 1),
              const SizedBox(height: 20),

              // ── Bottom bar ──
              Row(children: [
                Text(
                  '© 2025 PWT. All rights reserved.',
                  style: AppText.muted.copyWith(color: const Color(0xFF8899BB)),
                ),
                const Spacer(),
                if (wide) ...[
                  InkWell(
                    onTap: () {},
                    child: Text('Privacy Policy',
                        style: AppText.muted.copyWith(color: const Color(0xFF8899BB))),
                  ),
                  const SizedBox(width: 28),
                  InkWell(
                    onTap: () {},
                    child: Text('Terms of Service',
                        style: AppText.muted.copyWith(color: const Color(0xFF8899BB))),
                  ),
                ],
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a storefront page: header + scrollable body (with footer) + WA fab.
class StoreScaffold extends StatelessWidget {
  final String active;
  final List<Widget> slivers;
  final bool showFooter;
  const StoreScaffold({super.key, required this.active, required this.slivers, this.showFooter = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SiteHeader(active: active),
      floatingActionButton: const WhatsAppFab(),
      body: CustomScrollView(
        slivers: [
          ...slivers,
          if (showFooter) const SliverToBoxAdapter(child: SiteFooter()),
        ],
      ),
    );
  }
}

/// Centered max-width content band used across storefront sections.
class Band extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double maxWidth;
  const Band({super.key, required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 40), this.color, this.maxWidth = 1280});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: padding,
      child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child)),
    );
  }
}

/// Small eyebrow label used above section titles.
class Eyebrow extends StatelessWidget {
  final String text;
  const Eyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      // decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text.toUpperCase(),
          style: AppText.muted.copyWith(color: AppColors.blue700, fontWeight: FontWeight.bold, letterSpacing: 0.6, fontSize: 13)),
    );
  }
}
