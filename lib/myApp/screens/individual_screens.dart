// Individual user shell: Devices (hero slider home) + Shop (catalogue).
// Ported from proto/individual.jsx. Overlays (PDP, cart, maintenance, account)
// are pushed as routes — see screens/overlays.dart and the *_screens files.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/cart_state.dart';
import '../widgets/chrome.dart';
import '../widgets/primitives.dart';
import '../widgets/empty_states.dart';
import '../widgets/floating_trial_badge.dart';
import '../widgets/pwt_icons.dart';
import 'account_screens.dart';
import 'business_screens.dart' show RequestRfqScreen;
import 'cart_screen.dart';
import 'overlays.dart';
import 'product_detail_screen.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Machines/get_machines.dart';
import '../../Backend/Maintenance/get_maintenance_requests.dart';
import '../../Backend/Categories/get_categories.dart';
import '../../Backend/Products/get_products.dart';
import '../../Backend/Orders/get_orders.dart';
import '../../Models/category_model.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Maintenance/maintenance_request_model.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Models/Products/products_model.dart';

String? fmtDeviceDate(String? iso) {
  if (iso == null) return null;
  try {
    final dt = DateTime.parse(iso);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) { return iso; }
}


class IndividualShell extends StatefulWidget {
  const IndividualShell({super.key, required this.onLogout, this.isNew = false});
  final VoidCallback onLogout;
  final bool isNew;

  @override
  State<IndividualShell> createState() => _IndividualShellState();
}

class _IndividualShellState extends State<IndividualShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _productsKey = GlobalKey<ProductsScreenState>();
  final _ordersKey = GlobalKey<_IndividualOrdersScreenState>();
  String _tab = 'home';
  List<MachineModel> _machines = [];
  bool _loadingMachines = true;
  bool _loadingMoreMachines = false;
  int _machinesPage = 1;
  PaginationModel? _machinesPagination;
  String? _machinesError;

  bool get _isGuest => web.AppState.instance.user == null;

  @override
  void initState() {
    super.initState();
    if (!_isGuest) _loadMachines();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = context.read<AppState>();
      final pending = appState.pendingProduct;
      if (pending != null) {
        appState.clearPendingProduct();
        _push(ProductDetailScreen(product: pending, role: AccountKind.individual));
      }
    });
  }

  void _onProfileTap() {
    if (_isGuest) {
      context.read<AppState>().go(AppRoute.login);
    } else {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  Future<void> _loadMachines({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMoreMachines = true);
    } else {
      setState(() { _loadingMachines = true; _machinesError = null; });
    }
    final res = await getMachines(page: page);
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _machines = append ? [..._machines, ...res.data!.items] : res.data!.items;
        _machinesPagination = res.data!.pagination;
        _machinesPage = page;
        _machinesError = null;
      } else if (!append) {
        _machinesError = res.message ?? res.error ?? 'Failed to load machines. Please check your connection and try again.';
      }
      _loadingMachines = false;
      _loadingMoreMachines = false;
    });
  }

  AppUser get _user {
    final u = web.AppState.instance.user;
    return AppUser(
      name: u?.name ?? '',
      initials: u?.initials ?? 'PW',
      phone: u?.phone ?? '',
      email: u?.email ?? '',
      kind: AccountKind.individual,
      addressLabel: '',
    );
  }

  void _onDrawerSelect(String key) {
    Navigator.of(context).pop(); // close drawer
    switch (key) {
      case 'logout':
        widget.onLogout();
      case 'profile':
        _push(ProfileScreen(user: _user, role: AccountKind.individual));
      case 'settings':
        _push(const SettingsScreen());
      case 'invoices':
        _push(InvoicesScreen(invoices: MockData.individualInvoices));
    }
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _devicesTab() {
    if (_loadingMachines) {
      return BrandBackdrop(child: Column(children: [
        AppHeader(user: _user, onProfile: _onProfileTap),
        const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand))),
      ]));
    }
    if (_machinesError != null) {
      return _DevicesError(user: _user, onProfile: _onProfileTap, onRetry: _loadMachines);
    }
    if (_machines.isEmpty) {
      return _DevicesEmpty(user: _user, onProfile: _onProfileTap, onBrowse: () => setState(() => _tab = 'products'));
    }
    return IndividualHome(
      machines: _machines,
      user: _user,
      onProfile: _onProfileTap,
      onMaintenance: (m) => _push(MaintenanceSheet(machine: m)),
      onTrackOrder: () => _push(const OrdersScreen(role: AccountKind.individual)),
      loadingMore: _loadingMoreMachines,
      onLoadMore: (_machinesPagination != null && _machinesPage < (_machinesPagination!.lastPage ?? 1) && !_loadingMoreMachines)
          ? () => _loadMachines(page: _machinesPage + 1, append: true)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final isGuest = _isGuest;
    final tabs = isGuest ? ['home', 'products'] : ['home', 'products', 'devices', 'orders'];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PwtColors.bg,
      endDrawer: ProfileDrawer(user: _user, onSelect: _onDrawerSelect),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WhatsAppFab(),
          const SizedBox(height: 14),
          FloatingCart(onTap: () => _push(const CartScreen(role: AccountKind.individual))),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tabs.indexOf(_tab),
          children: [
            _HomeTab(
              user: _user,
              onProfile: _onProfileTap,
              isGuest: isGuest,
              onMachines: () => setState(() => _tab = 'devices'),
              onOrders: () => setState(() => _tab = 'orders'),
              onExplore: () => setState(() => _tab = 'products'),
            ),
            ProductsScreen(
              key: _productsKey,
              user: _user,
              role: AccountKind.individual,
              onProfile: _onProfileTap,
              onOpenProduct: (p) => _push(ProductDetailScreen(product: p, role: AccountKind.individual)),
            ),
            if (!isGuest) _devicesTab(),
            if (!isGuest)
              IndividualOrdersScreen(
                key: _ordersKey,
                user: _user,
                onProfile: _onProfileTap,
                onBrowse: () => setState(() => _tab = 'products'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: PwtBottomNav(
        active: _tab,
        onChanged: (k) {
          setState(() => _tab = k);
          if (k == 'devices' && _machinesError != null) _loadMachines();
          if (k == 'products') _productsKey.currentState?.retryIfFailed();
          if (k == 'orders') _ordersKey.currentState?.refresh();
        },
        items: [
          PwtNavItem(key: 'home', label: s['home']!, icon: Icons.home_outlined),
          PwtNavItem(key: 'products', label: s['shop']!, icon: PwtIcons.cube),
          if (!isGuest) ...[
            PwtNavItem(key: 'devices', label: s['devices']!, icon: PwtIcons.drop),
            PwtNavItem(key: 'orders', label: s['orders']!, icon: PwtIcons.orders),
          ],
        ],
      ),
    );
  }
}

// ─── Home tab: hero (ported from myWeb2's storefront hero) + quick actions ───
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.user, required this.onProfile, required this.isGuest, this.onMachines, this.onOrders, this.onExplore});
  final AppUser user;
  final VoidCallback onProfile;
  final bool isGuest;
  final VoidCallback? onMachines;
  final VoidCallback? onOrders;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final ar = app.isArabic;
    final firstName = user.name.trim().isNotEmpty ? user.name.trim().split(' ').first : '';

    return BrandBackdrop(
      opacity: 0.1,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppHeader(user: user, onProfile: onProfile),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isGuest && firstName.isNotEmpty) ...[
                  Text.rich(
                    TextSpan(
                      style: PwtType.headline(arabic: ar).copyWith(fontSize: 20, height: 1.3),
                      children: [
                        TextSpan(text: '${s['hello']!}\n', style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                        TextSpan(text: '$firstName 👋'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    // const Icon(PwtIcons.drop, size: 16, color: PwtColors.brand),
                    // const SizedBox(width: 6),
                    Text(s['pureWaterPureLife']!,
                      style: PwtType.headline(arabic: ar).copyWith(fontSize: 27, height: 1.2),
                        // style: PwtType.eyebrow(color: PwtColors.brand).copyWith(fontSize: 27, fontWeight: FontWeight.w700)
                     ),
                  ],
                ),
                // const SizedBox(height: 10),
                // Text.rich(
                //   TextSpan(
                //     style: PwtType.headline(arabic: ar).copyWith(fontSize: 27, height: 1.2),
                //     children: [
                //       TextSpan(text: s['homeHeadlinePlain']!),
                //       TextSpan(text: s['homeHeadlineAccent']!, style: const TextStyle(color: PwtColors.brand)),
                //       TextSpan(text: ' ${s['homeHeadlineTail']!}'),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 10),
                // Text(s['homeHeroSub']!, style: PwtType.body(color: PwtColors.textSec, arabic: ar).copyWith(fontSize: 13.5, height: 1.55)),

                const SizedBox(height: 18),
                Stack(clipBehavior: Clip.none, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/podium-hero.png',
                      height: 210,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(height: 210),
                    ),
                  ),
                  const Positioned(
                    top: -10,
                    right: -6,
                    child: FloatingTrialBadge(),
                  ),
                ]),
                const SizedBox(height: 16),
                PwtButton(label: s['exploreProducts']!, trailing: PwtIcons.arrow, onPressed: onExplore),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: isGuest
                ? Column(
                    children: [
                      Center(child: Eyebrow(ar ? 'حلول تناسب الجميع' : 'Solutions for Everyone')),
                      const SizedBox(height: 10),
                      Text(
                        ar ? 'اختر ما يناسبك' : 'Choose What Suits You Best',
                        textAlign: TextAlign.center,
                        style: PwtType.headline(arabic: ar).copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 18),
                      _SolutionCard(
                        icon: PwtIcons.user,
                        title: ar ? 'للأفراد' : 'For Individuals',
                        intro: ar ? 'اشترِ أو استأجر أنظمة تنقية مياه متطورة لمنزلك.' : 'Buy or rent premium water purification systems for your home.',
                        points: ar
                            ? const ['شراء فوري أو خيارات إيجار مرنة', 'طلبات بالجملة', 'توصيل وتركيب سريع']
                            : const ['Instant purchase or flexible rental options', 'Bulk orders', 'Fast delivery & installation'],
                        image: 'assets/images/sol-individuals.png',
                        ctaLabel: ar ? 'تسوّق الآن' : 'Shop Now',
                        solid: true,
                        onTap: onExplore,
                      ),
                      const SizedBox(height: 14),
                      _SolutionCard(
                        icon: PwtIcons.building,
                        title: ar ? 'للشركات' : 'For Companies',
                        intro: ar ? 'احصل على عرض سعر مخصص يناسب احتياجات شركتك.' : 'Get a customised quotation tailored to your business needs.',
                        points: ar
                            ? const ['تسعير مخصص', 'طلبات بالجملة', 'مدير حساب مخصص', 'دعم مخصص']
                            : const ['Personalised pricing', 'Bulk orders', 'Dedicated account manager', 'Dedicated support'],
                        image: 'assets/images/sol-companies.png',
                        ctaLabel: s['requestQuotation']!,
                        solid: false,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestRfqScreen())),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _QuickActionCard(
                          icon: PwtIcons.drop,
                          title: s['devices']!,
                          subtitle: s['myMachinesQaSub']!,
                          onTap: onMachines),
                      const SizedBox(height: 12),
                      _QuickActionCard(icon: PwtIcons.orders, title: s['orders']!, subtitle: s['ordersQaSub']!, onTap: onOrders, color: PwtColors.success),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, required this.subtitle, this.onTap, this.color = PwtColors.brand});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PwtColors.surface,
          border: Border.all(color: PwtColors.hairline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: PwtType.caption(color: PwtColors.textSec).copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(PwtIcons.caret, size: 16, color: PwtColors.textTer),
          ],
        ),
      ),
    );
  }
}

// ─── Guest-only "Solutions" card (ported from myWeb2's homepage) ───
class _SolutionCard extends StatelessWidget {
  const _SolutionCard({
    required this.icon,
    required this.title,
    required this.intro,
    required this.points,
    required this.image,
    required this.ctaLabel,
    required this.solid,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String intro;
  final List<String> points;
  final String image;
  final String ctaLabel;
  final bool solid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PwtColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PwtColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 18, color: PwtColors.brand),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: PwtType.title().copyWith(fontSize: 16, fontWeight: FontWeight.w800))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(intro, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13, height: 1.4)),
                const SizedBox(height: 10),
                for (final p in points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(PwtIcons.check, size: 14, color: PwtColors.brand),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: PwtType.body().copyWith(fontSize: 12.5))),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                PwtButton(
                  label: ctaLabel,
                  variant: solid ? PwtButtonVariant.primary : PwtButtonVariant.secondary,
                  size: PwtButtonSize.sm,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: PwtColors.surface2),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key, this.opacity = 0.18, required this.child});
  final double opacity;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1.0),
                radius: 0.9,
                colors: [PwtColors.brand.withValues(alpha: opacity), PwtColors.brand.withValues(alpha: 0)],
                stops: const [0, 0.7],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ─── Individual home: device hero slider + detail card ───
class IndividualHome extends StatefulWidget {
  const IndividualHome({
    super.key,
    required this.machines,
    required this.user,
    required this.onProfile,
    required this.onMaintenance,
    required this.onTrackOrder,
    this.loadingMore = false,
    this.onLoadMore,
  });

  final List<MachineModel> machines;
  final AppUser user;
  final VoidCallback onProfile;
  final ValueChanged<MachineModel> onMaintenance;
  final VoidCallback onTrackOrder;
  final bool loadingMore;
  final VoidCallback? onLoadMore;

  @override
  State<IndividualHome> createState() => _IndividualHomeState();
}

class _IndividualHomeState extends State<IndividualHome> {
  final _controller = PageController();
  int _idx = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final machine = widget.machines[_idx];
    final isOrdered = machine.status == 'ordered';

    return BrandBackdrop(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppHeader(user: widget.user, onProfile: widget.onProfile),
          const SizedBox(height: 8),
          // hero slider
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.machines.length,
              onPageChanged: (i) => setState(() => _idx = i),
              itemBuilder: (_, i) {
                final m = widget.machines[i];
                final code = m.product.code;
                final tint = MockData.productById(code)?.tint ?? PwtColors.brand;
                final mId = m.displayName ?? m.serialNumber;
                return Column(
                  children: [
                    Expanded(child: ProductImage(img: 'assets/products/$code.png', imageUrl: m.product.imageUrl, size: 240, accent: tint)),
                    const SizedBox(height: 8),
                    Text(m.product.code, style: PwtType.headline().copyWith(fontSize: 28)),
                    const SizedBox(height: 6),
                    if (m.status == 'ordered')
                      Pill(label: s['deviceOrdered']!, color: PwtColors.warning, dot: true)
                    else
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(mId!, style: PwtType.mono(size: 12, color: PwtColors.textTer)),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.machines.length; i++)
                GestureDetector(
                  onTap: () => _controller.animateToPage(i, duration: PwtMotion.normal, curve: PwtMotion.standard),
                  child: AnimatedContainer(
                    duration: PwtMotion.normal,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _idx ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _idx ? PwtColors.brand : PwtColors.hairline2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: isOrdered
                ? OrderedDeviceCard(machine: machine, onTrackOrder: widget.onTrackOrder)
                : _DeviceCard(machine: machine, onMaintenance: () => widget.onMaintenance(machine)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(child: Text(s['swipeForMore']!, style: PwtType.caption().copyWith(fontSize: 11.5))),
          ),
          // quick actions
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 4, bottom: 10),
          //         child: Eyebrow(app.isArabic ? 'إجراءات سريعة' : 'Quick actions'),
          //       ),
          //       Row(
          //         children: [
          //           _QuickAction(icon: PwtIcons.orders, label: s['orders']!),
          //           const SizedBox(width: 10),
          //           _QuickAction(icon: PwtIcons.cube, label: s['products']!),
          //           const SizedBox(width: 10),
          //           _QuickAction(icon: PwtIcons.message, label: app.isArabic ? 'تواصل معنا' : 'Contact us'),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          if (widget.loadingMore)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
            )
          else if (widget.onLoadMore != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PwtButton(label: 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: widget.onLoadMore),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.machine, required this.onMaintenance});
  final MachineModel machine;
  final VoidCallback onMaintenance;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final isRent = machine.term == 'rent';
    final location = machine.locationLabel?.isNotEmpty == true
        ? machine.locationLabel
        : (machine.address != null ? '${machine.address!.label} · ${machine.address!.city}' : null);

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
          // purchase strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: PwtColors.surface2,
              border: Border(bottom: BorderSide(color: PwtColors.hairline)),
            ),
            child: Row(
              children: [
                Pill(label: isRent ? s['rent']! : s['buy']!, color: isRent ? PwtColors.brand : PwtColors.success),
                const SizedBox(width: 8),
                if (machine.productPrice != null)
                  Text(
                    '${machine.productPrice!.currency} ${machine.productPrice!.amount}${isRent ? '/mo' : ''}',
                    style: PwtType.caption(color: PwtColors.textSec).copyWith(fontWeight: FontWeight.w600),
                  ),
                const Spacer(),
                Flexible(child: Text(location ?? '', style: PwtType.eyebrow().copyWith(fontSize: 11, letterSpacing: 0), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          // service dates
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(child: _DateBlock(label: isRent ? s['rent']! : s['purchased']!, value: fmtDeviceDate(machine.installedAt) ?? '—')),
                if (machine.nextMaintenanceDueAt != null)
                  Expanded(child: _DateBlock(label: s['nextService']!, value: fmtDeviceDate(machine.nextMaintenanceDueAt)!, accent: PwtColors.warning, divider: true)),
              ],
            ),
          ),
          // maintenance action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PwtButton(label: s['requestMaintenance']!, full: true, icon: PwtIcons.wrench, onPressed: onMaintenance),
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.label, required this.value, this.accent, this.divider = false});
  final String label;
  final String value;
  final Color? accent;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: divider ? 14 : 0),
      decoration: BoxDecoration(
        border: divider ? const Border(left: BorderSide(color: PwtColors.hairline)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: PwtType.eyebrow().copyWith(fontSize: 10.5, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: PwtType.subtitle(color: accent ?? PwtColors.textPri).copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
        decoration: BoxDecoration(
          color: PwtColors.surface,
          border: Border.all(color: PwtColors.hairline),
          borderRadius: BorderRadius.circular(16),
          boxShadow: PwtShadows.e1,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: PwtColors.brand),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: PwtType.label(weight: FontWeight.w500).copyWith(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

/// Awaiting-delivery card with a 4-step progress tracker.
class OrderedDeviceCard extends StatelessWidget {
  const OrderedDeviceCard({super.key, required this.machine, required this.onTrackOrder});
  final MachineModel machine;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final steps = [
      (label: app.isArabic ? 'تم الطلب' : 'Ordered', done: true),
      (label: app.isArabic ? 'التجهيز' : 'Preparing', done: true),
      (label: app.isArabic ? 'الشحن' : 'Shipping', done: false),
      (label: app.isArabic ? 'التسليم' : 'Delivered', done: false),
    ];
    return Container(
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(PwtRadius.card),
        boxShadow: PwtShadows.e1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0x1AF59E0B),
              border: Border(bottom: BorderSide(color: PwtColors.hairline)),
            ),
            child: Row(
              children: [
                const Icon(PwtIcons.truck, size: 20, color: PwtColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['deviceOrdered']!, style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 13.5)),
                      Text(s['arrivingSoon']!, style: PwtType.caption(color: PwtColors.textSec).copyWith(fontSize: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['estDelivery']!.toUpperCase(), style: PwtType.eyebrow().copyWith(fontSize: 10.5, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(PwtIcons.cal, size: 18, color: PwtColors.brand),
                    const SizedBox(width: 8),
                    Text('', style: PwtType.subtitle().copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  machine.locationLabel?.isNotEmpty == true
                      ? machine.locationLabel!
                      : (machine.address != null ? '${machine.address!.label} · ${machine.address!.city}' : ''),
                  style: PwtType.caption().copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                for (int i = 0; i < steps.length; i++) ...[
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: steps[i].done ? PwtColors.brand : PwtColors.surface2,
                          border: steps[i].done ? null : Border.all(color: PwtColors.hairline2, width: 1.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(steps[i].label, style: PwtType.caption(color: steps[i].done ? PwtColors.textPri : PwtColors.textTer).copyWith(fontSize: 9.5, fontWeight: steps[i].done ? FontWeight.w600 : FontWeight.w500)),
                    ],
                  ),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.only(bottom: 18),
                        color: steps[i + 1].done ? PwtColors.brand : PwtColors.hairline2,
                      ),
                    ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: PwtButton(label: s['trackOrder']!, variant: PwtButtonVariant.soft, size: PwtButtonSize.md, full: true, icon: PwtIcons.truck, onPressed: onTrackOrder),
          ),
        ],
      ),
    );
  }
}

// ─── Products catalogue (shared by individual + business) ───
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    required this.user,
    required this.role,
    required this.onProfile,
    required this.onOpenProduct,
  });

  final AppUser user;
  final AccountKind role;
  final VoidCallback onProfile;
  final ValueChanged<ProductModel> onOpenProduct;

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  PaginationModel? _pagination;
  int? _selectedCategoryId;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String? _error;

  /// Called by the shell when this tab is reselected — re-fetches only if
  /// the last attempt failed, so switching tabs doesn't hammer the API on
  /// the happy path but does recover once connectivity comes back.
  void retryIfFailed() {
    if (_error != null) _load();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _load();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _load();
    });
  }

  Future<void> _loadCategories() async {
    final res = await getCategories();
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() => _categories = res.data!);
    }
  }

  Future<void> _load({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() { _loading = true; _products = []; _error = null; });
    }
    final query = _searchCtrl.text.trim();
    final res = await getProducts(
      page: page,
      search: query.isEmpty ? null : query,
      categoryId: _selectedCategoryId,
    );
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _products = append ? [..._products, ...res.data!.items] : res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
        _error = null;
      } else if (!append) {
        _error = res.message ?? res.error ?? 'Failed to load products. Please check your connection and try again.';
      }
      _loading = false;
      _loadingMore = false;
    });
  }

  void _loadMore() => _load(page: _page + 1, append: true);

  void _selectCategory(int? id) {
    setState(() => _selectedCategoryId = id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final ar = app.isArabic;

    return BrandBackdrop(
      opacity: 0.08,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppHeader(user: widget.user, onProfile: widget.onProfile),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s['catalogue']!),
                const SizedBox(height: 4),
                Text(s['products']!, style: PwtType.headline().copyWith(fontSize: 28)),
                if (widget.role == AccountKind.business) ...[
                  const SizedBox(height: 6),
                  Text(ar ? 'تصفّح المنتجات واطلب عرض سعر جديد.' : 'Browse products and request a new quotation.', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
                ],
              ],
            ),
          ),
          // search field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: PwtColors.surface,
                border: Border.all(color: PwtColors.hairline),
                borderRadius: BorderRadius.circular(PwtRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(PwtIcons.search, size: 18, color: PwtColors.textTer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
                      style: PwtType.body().copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: ar ? 'بحث في المنتجات…' : 'Search products…',
                        hintStyle: PwtType.body(color: PwtColors.textTer).copyWith(fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () { _searchCtrl.clear(); _load(); },
                      child: const Icon(Icons.close, size: 16, color: PwtColors.textTer),
                    ),
                ],
              ),
            ),
          ),
          // category chips
          if (_categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                children: [
                  _CatChip(
                    label: ar ? 'الكل' : 'All',
                    on: _selectedCategoryId == null,
                    onTap: () => _selectCategory(null),
                  ),
                  for (final cat in _categories)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _CatChip(
                        label: cat.name ?? '',
                        on: _selectedCategoryId == cat.id,
                        onTap: () => _selectCategory(cat.id),
                      ),
                    ),
                ],
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
            )
          else if (_products.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: _error != null ? PwtColors.error.withValues(alpha: 0.1) : PwtColors.brandTint,
                      shape: BoxShape.circle,
                      border: _error != null ? Border.all(color: PwtColors.error) : null,
                    ),
                    child: Icon(_error != null ? PwtIcons.warn : PwtIcons.cube, size: 32, color: _error != null ? PwtColors.error : PwtColors.brand),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _error != null
                        ? (ar ? 'تعذّر تحميل المنتجات' : 'Couldn\'t load products')
                        : (_searchCtrl.text.trim().isNotEmpty || _selectedCategoryId != null
                            ? (ar ? 'لا توجد نتائج' : 'No matching products')
                            : s['products']!),
                    style: PwtType.title().copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error != null
                        ? (ar ? 'حدث خطأ ما. يرجى التحقق من الاتصال والمحاولة مرة أخرى.' : 'Something went wrong. Please check your connection and try again.')
                        : (_searchCtrl.text.trim().isNotEmpty || _selectedCategoryId != null
                            ? (ar ? 'جرّب بحثاً أو تصنيفاً مختلفاً.' : 'Try a different search or category.')
                            : (ar ? 'لا توجد منتجات متاحة حالياً.' : 'No products available at the moment.')),
                    textAlign: TextAlign.center,
                    style: PwtType.body(color: PwtColors.textSec),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 20),
                    PwtButton(label: s['retry']!, variant: PwtButtonVariant.soft, onPressed: () => _load()),
                  ],
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final p in _products)
                    _ProductCard(product: p, onTap: () => widget.onOpenProduct(p)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  if (_pagination != null)
                    Text(
                      'Page $_page of ${_pagination!.lastPage ?? 1} · ${_pagination!.total ?? _products.length} total',
                      textAlign: TextAlign.center,
                      style: PwtType.caption().copyWith(fontSize: 12),
                    ),
                  if (_page < (_pagination?.lastPage ?? 1)) ...[
                    const SizedBox(height: 12),
                    if (_loadingMore)
                      const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand),
                      ))
                    else
                      PwtButton(label: s['loadMore'] ?? 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: _loadMore),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? PwtColors.brandTint : PwtColors.surface,
          border: Border.all(color: on ? PwtColors.brandBorder : PwtColors.hairline),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: on ? FontWeight.w600 : FontWeight.w500, color: on ? PwtColors.brandDeep : PwtColors.textSec)),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});
  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final isQuote = product.isQuoteOnly ?? false;
    final price = product.startingPrice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: PwtColors.surface,
          border: Border.all(color: PwtColors.hairline),
          borderRadius: BorderRadius.circular(PwtRadius.card),
          boxShadow: PwtShadows.e1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: PwtColors.surface2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (product.primaryImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          product.primaryImageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 52, color: PwtColors.brandBorder),
                        ),
                      )
                    else
                      const Icon(PwtIcons.drop, size: 52, color: PwtColors.brandBorder),
                    if (product.tagLabel != null)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: PwtColors.brand, borderRadius: BorderRadius.circular(999)),
                          child: Text(product.tagLabel!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    if (isQuote)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: PwtColors.bgElev,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: PwtColors.hairline),
                          ),
                          child: Text(app.isArabic ? 'عرض' : 'Quote', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 9)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((product.category?.name ?? '').isNotEmpty) ...[
                    Eyebrow(product.category!.name!),
                    const SizedBox(height: 4),
                  ],
                  Text(product.code ?? product.name ?? '', style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (isQuote)
                    Text(s['quoteOnly']!, style: PwtType.caption(color: PwtColors.textPri).copyWith(fontSize: 11.5, fontWeight: FontWeight.w600))
                  else if (price != null)
                    Row(
                      children: [
                        Text('${s['fromPrice']} ', style: PwtType.caption().copyWith(fontSize: 11.5)),
                        Text('${price.currency} ', style: PwtType.caption(color: PwtColors.textPri).copyWith(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        Text(_fmtAmt(price.amount), style: PwtType.caption(color: PwtColors.textPri).copyWith(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        if (price.term == 'rent') Text(s['perMonth']!, style: PwtType.caption().copyWith(fontSize: 11.5)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtAmt(String amount) {
    final v = double.tryParse(amount);
    return v != null ? v.toStringAsFixed(0) : amount;
  }
}

// ─── Empty devices state (first-time signup) ───
class _DevicesEmpty extends StatefulWidget {
  const _DevicesEmpty({required this.user, required this.onProfile, required this.onBrowse});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback onBrowse;

  @override
  State<_DevicesEmpty> createState() => _DevicesEmptyState();
}

class _DevicesEmptyState extends State<_DevicesEmpty> {
  List<ProductModel> _teaserProducts = [];

  @override
  void initState() {
    super.initState();
    _loadTeasers();
  }

  Future<void> _loadTeasers() async {
    final res = await getProducts(page: 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() => _teaserProducts = res.data!.items.take(3).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    return BrandBackdrop(
      child: ListView(
        children: [
          AppHeader(user: widget.user, onProfile: widget.onProfile),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s['welcomeBack']!),
                const SizedBox(height: 4),
                Text('${widget.user.name.split(' ').first} 👋', style: PwtType.headline().copyWith(fontSize: 24)),
              ],
            ),
          ),
          DevicesEmptyState(business: false, onBrowse: widget.onBrowse, teaserProducts: _teaserProducts),
        ],
      ),
    );
  }
}

// ─── Devices load error ───
class _DevicesError extends StatelessWidget {
  const _DevicesError({required this.user, required this.onProfile, required this.onRetry});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return BrandBackdrop(
      child: ListView(
        children: [
          AppHeader(user: user, onProfile: onProfile),
          const SizedBox(height: 60),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: PwtColors.error.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: PwtColors.error)),
              child: const Icon(PwtIcons.warn, size: 32, color: PwtColors.error),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: Text(s['devicesLoadError']!, style: PwtType.title().copyWith(fontSize: 20))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(s['devicesLoadErrorSub']!, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: PwtButton(label: s['retry']!, full: true, onPressed: onRetry),
          ),
        ],
      ),
    );
  }
}

// ─── Individual maintenance requests ───
class IndividualRequestsScreen extends StatefulWidget {
  const IndividualRequestsScreen({super.key, required this.user, required this.onProfile, required this.onSchedule});
  final AppUser user;
  final VoidCallback onProfile;
  final ValueChanged<MachineModel> onSchedule;

  @override
  State<IndividualRequestsScreen> createState() => _IndividualRequestsScreenState();
}

class _IndividualRequestsScreenState extends State<IndividualRequestsScreen> {
  List<MaintenanceRequestModel> _requests = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  PaginationModel? _pagination;
  String? _error;

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _issueLabels = {
    'filter_change': 'Filter Change', 'leak': 'Leak', 'noise': 'Noise',
    'low_pressure': 'Low Pressure', 'water_quality': 'Water Quality',
    'error_code': 'Error Code', 'installation_fix': 'Installation Fix', 'other': 'Other',
  };

  static const _slotLabels = {
    'morning':   'Morning (8AM – 12PM)',
    'afternoon': 'Afternoon (12PM – 4PM)',
    'evening':   'Evening (4PM – 7PM)',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() { _loading = true; _requests = []; _error = null; });
    }
    final res = await getMaintenanceRequests(page: page);
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _requests = append ? [..._requests, ...res.data!.items] : res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
        _error = null;
      } else if (!append) {
        _error = res.message ?? res.error ?? 'Failed to load requests. Please check your connection and try again.';
      }
      _loading = false;
      _loadingMore = false;
    });
  }

  void _loadMore() => _load(page: _page + 1, append: true);

  String _fmtDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}';
    } catch (_) { return '—'; }
  }

  Color _statusColor(String st) => switch (st) {
    'pending'     => PwtColors.warning,
    'new'         => PwtColors.warning,
    'scheduled'   => PwtColors.brand,
    'in_progress' => PwtColors.brand,
    'completed'   => PwtColors.success,
    'cancelled'   => PwtColors.error,
    _             => PwtColors.textSec,
  };

  String _statusLabel(String st) => switch (st) {
    'pending'     => 'Pending',
    'new'         => 'Pending',
    'scheduled'   => 'Scheduled',
    'in_progress' => 'In Progress',
    'completed'   => 'Completed',
    'cancelled'   => 'Cancelled',
    _             => st,
  };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AppHeader(user: widget.user, onProfile: widget.onProfile),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(s['requests']!),
              const SizedBox(height: 4),
              Text(s['maintenanceRequests']!, style: PwtType.headline().copyWith(fontSize: 28)),
            ],
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
          )
        else if (_requests.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
            child: Column(
              children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: _error != null ? PwtColors.error.withValues(alpha: 0.1) : PwtColors.brandTint,
                    shape: BoxShape.circle,
                    border: Border.all(color: _error != null ? PwtColors.error : PwtColors.brandBorder),
                  ),
                  child: Icon(_error != null ? PwtIcons.warn : PwtIcons.wrench, size: 48, color: _error != null ? PwtColors.error : PwtColors.brand),
                ),
                const SizedBox(height: 22),
                Text(_error != null ? s['requestsLoadError']! : s['noRequestsYet']!, style: PwtType.title().copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Text(_error != null ? s['requestsLoadErrorSub']! : s['noRequestsSub']!, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5)),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  PwtButton(label: s['retry']!, variant: PwtButtonVariant.soft, onPressed: () => _load()),
                ],
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                for (final req in _requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _indRequestCard(req),
                  ),
                if (_pagination != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Page $_page of ${_pagination!.lastPage ?? 1} · ${_pagination!.total ?? _requests.length} total',
                    textAlign: TextAlign.center,
                    style: PwtType.caption().copyWith(fontSize: 12),
                  ),
                  if (_page < (_pagination!.lastPage ?? 1)) ...[
                    const SizedBox(height: 12),
                    if (_loadingMore)
                      const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand),
                      ))
                    else
                      PwtButton(label: 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: _loadMore),
                  ],
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _indRequestCard(MaintenanceRequestModel r) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MaintenanceApiDetailScreen(id: r.id))),
      child: Container(
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(PwtRadius.card),
        boxShadow: PwtShadows.e1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(r.displayName ?? r.publicId, style: PwtType.mono(size: 11.5, color: PwtColors.brand, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                Pill(label: _statusLabel(r.status), color: _statusColor(r.status), dot: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                const Icon(PwtIcons.wrench, size: 16, color: PwtColors.textTer),
                const SizedBox(width: 8),
                Text(_issueLabels[r.issueType] ?? r.issueType,
                    style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13)),
                const SizedBox(width: 6),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      r.preferredTime != null ? '· ${r.preferredDate}  ${_slotLabels[r.preferredTime] ?? r.preferredTime}' : '· ${r.preferredDate}',
                      style: PwtType.label(color: PwtColors.textTer).copyWith(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(r.machine.displayName ?? r.machine.serialNumber, style: PwtType.mono(size: 11, color: PwtColors.textTer)),
            ),
          ),
        ],
      ),
    ));
  }
}

// ─── Orders tab ───
class IndividualOrdersScreen extends StatefulWidget {
  const IndividualOrdersScreen({super.key, required this.user, required this.onProfile, this.onBrowse});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback? onBrowse;

  @override
  State<IndividualOrdersScreen> createState() => _IndividualOrdersScreenState();
}

class _IndividualOrdersScreenState extends State<IndividualOrdersScreen> {
  bool _loading = true;
  bool _loadingMore = false;
  bool _sortDesc = true;
  String? _statusFilter;
  List<OrderModel> _orders = [];
  int _page = 1;
  PaginationModel? _pagination;
  String? _errorMsg;

  static const _statusFilters = <String?>[null, 'pending', 'completed', 'cancelled'];
  static const _statusFilterLabels = ['All', 'Pending', 'Completed', 'Cancelled'];
  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  /// Called by the shell when this tab is reselected — re-fetches only if
  /// the last attempt failed.
  void retryIfFailed() {
    if (_errorMsg != null) _load();
  }

  /// Called by the shell every time the Orders tab is tapped — always
  /// re-fetches page 1 with the current filter/sort, so newly placed or
  /// updated orders show up without needing an app restart.
  void refresh() => _load();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() { _loading = true; _orders = []; _errorMsg = null; });
    }
    final res = await getOrders(page: page, status: _statusFilter, sort: 'created_at', order: _sortDesc ? 'desc' : 'asc');
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _orders = append ? [..._orders, ...res.data!.items] : res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
        _errorMsg = null;
      } else if (!append) {
        _errorMsg = res.message ?? res.error ?? 'Failed to load orders. Please check your connection and try again.';
      }
      _loading = false;
      _loadingMore = false;
    });
  }

  void _loadMore() => _load(page: _page + 1, append: true);

  String _fmtDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}';
    } catch (_) { return '—'; }
  }

  String _shortId(String publicId) =>
      '#${publicId.length >= 8 ? publicId.substring(0, 8).toUpperCase() : publicId.toUpperCase()}';

  Color _statusColor(String st) => switch (st) {
    'pending'   => PwtColors.warning,
    'placed'    => PwtColors.success,
    'confirmed' => PwtColors.brand,
    'scheduled' => PwtColors.brand,
    'completed' => PwtColors.success,
    'cancelled' => PwtColors.error,
    _           => PwtColors.textSec,
  };

  String _statusLabel(String st) => switch (st) {
    'pending'   => 'Pending',
    'placed'    => 'Placed',
    'confirmed' => 'Confirmed',
    'scheduled' => 'Scheduled',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    _           => st,
  };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    // Hide the sort toggle and status filter chips for the true empty state
    // (no data, no active filter, no error) — the empty-state design reads
    // cleaner without controls that have nothing to act on.
    final trueEmpty = !_loading && _orders.isEmpty && _errorMsg == null && _statusFilter == null;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AppHeader(user: widget.user, onProfile: widget.onProfile),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(app.isArabic ? 'طلبياتك' : 'Your orders'),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(s['orders']!, style: PwtType.headline().copyWith(fontSize: 28))),
                  if (!trueEmpty)
                  GestureDetector(
                    onTap: () { setState(() { _sortDesc = !_sortDesc; _page = 1; }); _load(); },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: PwtColors.surface, border: Border.all(color: PwtColors.hairline), borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(PwtIcons.sort, size: 15, color: PwtColors.textSec),
                        const SizedBox(width: 6),
                        Text(_sortDesc ? s['newestFirst']! : s['oldestFirst']!, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 12.5)),
                      ]),
                    ),
                  ),
                ],
              ),
              if (!trueEmpty) ...[
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_statusFilters.length, (i) {
                      final on = _statusFilter == _statusFilters[i];
                      return GestureDetector(
                        onTap: () {
                          setState(() { _statusFilter = _statusFilters[i]; _page = 1; });
                          _load();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: i < _statusFilters.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: on ? PwtColors.brandTint : PwtColors.surface,
                            border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline, width: on ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(_statusFilterLabels[i], style: PwtType.label(weight: on ? FontWeight.w700 : FontWeight.w500, color: on ? PwtColors.brand : PwtColors.textSec).copyWith(fontSize: 13)),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
          )
        else if (trueEmpty)
          OrdersEmptyState(onBrowse: widget.onBrowse ?? () {})
        else if (_orders.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 24),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _errorMsg != null ? PwtColors.error.withValues(alpha: 0.1) : PwtColors.brandTint,
                    shape: BoxShape.circle,
                    border: Border.all(color: _errorMsg != null ? PwtColors.error : PwtColors.brandBorder),
                  ),
                  child: Icon(_errorMsg != null ? PwtIcons.warn : PwtIcons.orders, size: 40, color: _errorMsg != null ? PwtColors.error : PwtColors.brand),
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMsg != null ? s['ordersLoadError']! : s['noOrdersFiltered']!,
                  style: PwtType.title().copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMsg != null ? s['ordersLoadErrorSub']! : s['noOrdersFilteredSub']!,
                  textAlign: TextAlign.center,
                  style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 20),
                  PwtButton(label: s['retry']!, variant: PwtButtonVariant.soft, onPressed: () => _load()),
                ],
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                for (final o in _orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _orderCard(o, s),
                  ),
                if (_pagination != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Page $_page of ${_pagination!.lastPage ?? 1} · ${_pagination!.total ?? _orders.length} total',
                    textAlign: TextAlign.center,
                    style: PwtType.caption().copyWith(fontSize: 12),
                  ),
                  if (_page < (_pagination!.lastPage ?? 1)) ...[
                    const SizedBox(height: 12),
                    if (_loadingMore)
                      const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand),
                      ))
                    else
                      PwtButton(label: 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: _loadMore),
                  ],
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _orderCard(OrderModel o, Map<String, String> s) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderApiDetailScreen(id: o.id))),
      child: PwtCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Directionality(textDirection: TextDirection.ltr, child: Text(o.displayName ?? _shortId(o.publicId), style: PwtType.mono(size: 11, color: PwtColors.brand, weight: FontWeight.w600))),
              Pill(label: _statusLabel(o.displayStatus), color: _statusColor(o.displayStatus), dot: true),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  o.firstProductName ?? 'Order #${o.id}',
                  style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (o.remainingItemsCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(999)),
                  child: Text('+${o.remainingItemsCount}', style: PwtType.mono(size: 11, color: PwtColors.brand, weight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text('${s['placed']} ${_fmtDate(o.placedAt)}', style: PwtType.caption().copyWith(fontSize: 12)),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Divider(height: 1, color: PwtColors.hairline),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${o.currency} ', style: PwtType.caption().copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(o.totalAmount, style: PwtType.subtitle().copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                  if (o.term == 'rent') Text(s['perMonth']!, style: PwtType.caption()),
                ],
              ),
              const Icon(PwtIcons.caret, size: 16, color: PwtColors.textTer),
            ],
          ),
        ],
      ),
    ));
  }
}
