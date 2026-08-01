// Business shell: Fleet (devices) · Requests (maintenance schedules) · Orders
// (with quotations) · Shop. Ported from proto/business.jsx, plus the
// ScheduleMaintenance + Quotation flows from proto/account.jsx.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../core/asset_resolver.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/cart_state.dart';
import '../widgets/chrome.dart';
import '../widgets/empty_states.dart';
import '../widgets/floating_trial_badge.dart';
import '../widgets/layout.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';
import 'account_screens.dart';
import 'cart_screen.dart';
import 'individual_screens.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Machines/get_machines.dart';
import '../../Backend/Maintenance/create_maintenance_request.dart';
import '../../Backend/Maintenance/get_maintenance_requests.dart';
import '../../Backend/Orders/get_orders.dart';
import '../../Backend/Orders/get_order_details.dart';
import 'account_screens.dart' show OrderApiDetailScreen;
import '../../Backend/Products/get_products.dart';
import '../../Backend/Rfq/create_rfq.dart';
import '../../Backend/Reference/get_countries.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/Reference/country_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Maintenance/maintenance_request_model.dart';
import '../../Models/Products/products_model.dart';
import '../../Models/Products/products_model.dart';
import 'overlays.dart';
import 'product_detail_screen.dart';


class BusinessShell extends StatefulWidget {
  const BusinessShell({super.key, required this.onLogout, this.isNew = false});
  final VoidCallback onLogout;
  final bool isNew;

  @override
  State<BusinessShell> createState() => _BusinessShellState();
}

class _BusinessShellState extends State<BusinessShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _productsKey = GlobalKey<ProductsScreenState>();
  final _ordersKey = GlobalKey<_BusinessOrdersScreenState>();
  final _requestsKey = GlobalKey<_BusinessRequestsScreenState>();
  String _tab = 'home';
  List<MachineModel> _machines = [];
  bool _loadingMachines = true;
  bool _loadingMoreMachines = false;
  int _machinesPage = 1;
  PaginationModel? _machinesPagination;
  int _statRented = 0;
  int _statPurchased = 0;
  String? _machineStatus; // null = all, 'rented', 'purchased'
  String? _machinesError;

  @override
  void initState() {
    super.initState();
    _loadMachines();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = context.read<AppState>();
      final pending = appState.pendingProduct;
      if (pending != null) {
        appState.clearPendingProduct();
        _push(ProductDetailScreen(product: pending, role: AccountKind.business));
      }
    });
  }

  Future<void> _loadMachines({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMoreMachines = true);
    } else {
      setState(() { _loadingMachines = true; _machinesError = null; });
    }
    final res = await getMachines(page: page, status: _machineStatus);
    if (!mounted) return;
    final stats = page == 1 ? (res.data?.meta?['stats'] as Map<String, dynamic>?) : null;
    setState(() {
      if (res.success && res.data != null) {
        _machines = append ? [..._machines, ...res.data!.items] : res.data!.items;
        _machinesPagination = res.data!.pagination;
        _machinesPage = page;
        _machinesError = null;
        if (stats != null) {
          _statRented    = stats['rented'] as int? ?? 0;
          _statPurchased = stats['purchased'] as int? ?? 0;
        }
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
      kind: AccountKind.business,
      addressLabel: '',
      company: u?.companyName != null && u!.companyName!.isNotEmpty
          ? Company(
              name: u.companyName!,
              trn: '',
              industry: '',
              address: '',
              contact: u.name ?? '',
              email: u.email ?? '',
            )
          : null,
    );
  }

  void _onDrawerSelect(String key) {
    Navigator.of(context).pop();
    switch (key) {
      case 'logout':
        widget.onLogout();
      case 'profile':
        _push(ProfileScreen(user: _user, role: AccountKind.business));
      case 'settings':
        _push(const SettingsScreen());
      case 'invoices':
        _push(InvoicesScreen(invoices: MockData.businessInvoices));
    }
  }

  void _push(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Future<void> _openSchedule({List<MachineModel>? presetMachines}) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ScheduleMaintenanceScreen(presetMachines: presetMachines ?? const [])),
    );
    if (submitted == true) _requestsKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final tabs = ['home', 'devices', 'requests', 'orders', 'products'];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PwtColors.bg,
      endDrawer: ProfileDrawer(user: _user, onSelect: _onDrawerSelect),
      floatingActionButton: const WhatsAppFab(),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tabs.indexOf(_tab),
          children: [
            _BusinessHomeTab(
              user: _user,
              onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
              onMachines: () => setState(() => _tab = 'devices'),
              onOrders: () => setState(() => _tab = 'orders'),
              onExplore: () => setState(() => _tab = 'products'),
            ),
            widget.isNew
                ? _BusinessEmpty(user: _user, onProfile: () => _scaffoldKey.currentState?.openEndDrawer(), onBrowse: () => setState(() => _tab = 'products'))
                : BusinessDevicesScreen(
                    user: _user,
                    machines: _machines,
                    loading: _loadingMachines,
                    loadingMore: _loadingMoreMachines,
                    errorMsg: _machinesError,
                    onRetry: () => _loadMachines(),
                    rented: _statRented,
                    purchased: _statPurchased,
                    statusFilter: _machineStatus,
                    onFilterChange: (s) { setState(() => _machineStatus = s); _loadMachines(); },
                    onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
                    onMaintenance: (m) => _openSchedule(presetMachines: [m]),
                    onLoadMore: (_machinesPagination != null && _machinesPage < (_machinesPagination!.lastPage ?? 1) && !_loadingMoreMachines)
                        ? () => _loadMachines(page: _machinesPage + 1, append: true)
                        : null,
                    onBrowse: () => setState(() => _tab = 'products'),
                  ),
            BusinessRequestsScreen(
              key: _requestsKey,
              user: _user,
              onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
              onSchedule: () => _openSchedule(),
            ),
            BusinessOrdersScreen(
              key: _ordersKey,
              user: _user,
              onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
              onBrowse: () => setState(() => _tab = 'products'),
            ),
            ProductsScreen(
              key: _productsKey,
              user: _user,
              role: AccountKind.business,
              onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
              onOpenProduct: (p) => _push(ProductDetailScreen(product: p, role: AccountKind.business)),
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
          if (k == 'orders') _ordersKey.currentState?.retryIfFailed();
          if (k == 'requests') _requestsKey.currentState?.retryIfFailed();
        },
        items: [
          PwtNavItem(key: 'home', label: s['home']!, icon: Icons.home_outlined),
          PwtNavItem(key: 'products', label: s['shop']!, icon: PwtIcons.cube),
          PwtNavItem(key: 'devices', label: s['devices']!, icon: PwtIcons.drop),
          PwtNavItem(key: 'requests', label: s['requests']!, icon: PwtIcons.wrench),
          PwtNavItem(key: 'orders', label: s['orders']!, icon: PwtIcons.orders),
        ],
      ),
    );
  }
}

// ─── Home tab: hero (ported from myWeb2's storefront hero) + quick actions ───
class _BusinessHomeTab extends StatelessWidget {
  const _BusinessHomeTab({required this.user, required this.onProfile, required this.onMachines, required this.onOrders, this.onExplore});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback onMachines;
  final VoidCallback onOrders;
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
                if (firstName.isNotEmpty) ...[
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
                    const Icon(PwtIcons.drop, size: 16, color: PwtColors.brand),
                    const SizedBox(width: 6),
                    Text(s['pureWaterPureLife']!, style: PwtType.eyebrow(color: PwtColors.brand).copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    style: PwtType.headline(arabic: ar).copyWith(fontSize: 27, height: 1.2),
                    children: [
                      TextSpan(text: s['homeHeadlinePlain']!),
                      TextSpan(text: s['homeHeadlineAccent']!, style: const TextStyle(color: PwtColors.brand)),
                      TextSpan(text: ' ${s['homeHeadlineTail']!}'),
                    ],
                  ),
                ),
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
            child: Column(
              children: [
                _HomeQuickActionCard(icon: PwtIcons.drop, title: s['devices']!, subtitle: s['devicesQaSub']!, onTap: onMachines),
                const SizedBox(height: 12),
                _HomeQuickActionCard(icon: PwtIcons.orders, title: s['orders']!, subtitle: s['ordersQaSub']!, onTap: onOrders, color: PwtColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickActionCard extends StatelessWidget {
  const _HomeQuickActionCard({required this.icon, required this.title, required this.subtitle, this.onTap, this.color = PwtColors.brand});
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

// ─── Fleet ───
class BusinessDevicesScreen extends StatelessWidget {
  const BusinessDevicesScreen({super.key, required this.user, required this.machines, required this.loading, this.loadingMore = false, this.errorMsg, this.onRetry, required this.rented, required this.purchased, this.statusFilter, this.onFilterChange, required this.onProfile, required this.onMaintenance, this.onLoadMore, this.onBrowse});
  final AppUser user;
  final List<MachineModel> machines;
  final bool loading;
  final bool loadingMore;
  final String? errorMsg;
  final VoidCallback? onRetry;
  final int rented;
  final int purchased;
  final String? statusFilter;
  final ValueChanged<String?>? onFilterChange;
  final VoidCallback onProfile;
  final ValueChanged<MachineModel> onMaintenance;
  final VoidCallback? onLoadMore;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    final total = rented + purchased;
    // Hide stats/filters for the true empty state (no data, no active
    // filter, no error) so the empty-state design isn't cluttered with a
    // "0 / 0 / 0" stat card and filter chips above it.
    final trueEmpty = !loading && machines.isEmpty && errorMsg == null && statusFilter == null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AppHeader(user: user, onProfile: onProfile),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pill(label: s['business']!),
                  const SizedBox(width: 10),
                  Expanded(child: Text(user.company!.name, overflow: TextOverflow.ellipsis, style: PwtType.caption().copyWith(fontSize: 12))),
                ],
              ),
              if (!trueEmpty) ...[
                const SizedBox(height: 14),
                PwtCard(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      _stat(s['devicesCount']!, Text('$total', style: _statStyle), '${s['rent']} · ${s['buy']}'),
                      _stat(s['rent']!, Text('$rented', style: _statStyle.copyWith(color: rented > 0 ? PwtColors.brand : PwtColors.textTer)), 'rented machines', divider: true),
                      _stat(s['buy']!, Text('$purchased', style: _statStyle.copyWith(color: purchased > 0 ? PwtColors.success : PwtColors.textTer)), 'purchased', divider: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!trueEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              for (final entry in [
                [null,       s['allDevices'] ?? 'All'],
                ['rented',   s['rent']       ?? 'Rented'],
                ['purchased', s['buy']       ?? 'Purchased'],
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onFilterChange?.call(entry[0] as String?),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: statusFilter == entry[0] ? PwtColors.brand : PwtColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: statusFilter == entry[0] ? PwtColors.brand : PwtColors.hairline),
                      ),
                      child: Text(entry[1] as String, style: PwtType.label().copyWith(fontSize: 13, color: statusFilter == entry[0] ? Colors.white : PwtColors.textPri)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: loading
              ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)))
              : machines.isEmpty && errorMsg == null && statusFilter == null
                  ? DevicesEmptyState(business: true, onBrowse: onBrowse ?? () {})
                  : machines.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: errorMsg != null ? PwtColors.error.withValues(alpha: 0.1) : PwtColors.brandTint,
                              shape: BoxShape.circle,
                              border: Border.all(color: errorMsg != null ? PwtColors.error : PwtColors.brandBorder),
                            ),
                            child: Icon(errorMsg != null ? PwtIcons.warn : PwtIcons.drop, size: 36, color: errorMsg != null ? PwtColors.error : PwtColors.brand),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            errorMsg != null ? s['devicesLoadError']! : 'No machines match this filter',
                            style: PwtType.title().copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              errorMsg != null ? s['devicesLoadErrorSub']! : 'Try a different filter.',
                              textAlign: TextAlign.center,
                              style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13),
                            ),
                          ),
                          if (errorMsg != null && onRetry != null) ...[
                            const SizedBox(height: 18),
                            PwtButton(label: s['retry']!, variant: PwtButtonVariant.soft, onPressed: onRetry),
                          ],
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        for (final m in machines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _BusinessDeviceCard(machine: m, onMaintenance: () => onMaintenance(m)),
                          ),
                        if (loadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
                          )
                        else if (onLoadMore != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: PwtButton(label: 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: onLoadMore),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }

  static const _statStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: PwtColors.textPri);

  Widget _stat(String label, Widget value, String sub, {bool divider = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(border: divider ? const Border(left: BorderSide(color: PwtColors.hairline)) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: PwtType.eyebrow().copyWith(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            value,
            const SizedBox(height: 2),
            Text(sub, style: PwtType.caption().copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _BusinessDeviceCard extends StatelessWidget {
  const _BusinessDeviceCard({required this.machine, required this.onMaintenance});
  final MachineModel machine;
  final VoidCallback onMaintenance;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final nextDue = machine.nextMaintenanceDueAt;
    final overdue = nextDue != null && (() { try { return DateTime.parse(nextDue).isBefore(DateTime.now()); } catch (_) { return false; } })();
    final isRent = machine.term == 'rent';
    final code = machine.product.code;
    final imgPath = 'assets/products/$code.png';
    final machineId = machine.publicId.isNotEmpty ? machine.publicId : machine.serialNumber;

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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: PwtColors.hairline)),
                  alignment: Alignment.center,
                  child: hasLocalAsset(imgPath)
                      ? Image(image: pwtImage(imgPath), height: 56, fit: BoxFit.contain)
                      : (machine.product.imageUrl != null && machine.product.imageUrl!.isNotEmpty
                          ? Image.network(machine.product.imageUrl!, height: 56, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 28, color: PwtColors.brand))
                          : const Icon(Icons.water_drop_outlined, size: 28, color: PwtColors.brand)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Pill(label: isRent ? s['rent']! : s['buy']!, color: isRent ? PwtColors.brand : PwtColors.success),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(machine.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: PwtType.subtitle().copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Directionality(textDirection: TextDirection.ltr, child: Text(machineId, style: PwtType.mono(size: 11.5, color: PwtColors.textTer))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: Row(
              children: [
                Expanded(child: _svc(isRent ? s['rent']! : s['purchased']!, fmtDeviceDate(machine.installedAt) ?? '—', false)),
                if (machine.nextMaintenanceDueAt != null)
                  Expanded(child: _svc(s['nextService']!, '${fmtDeviceDate(machine.nextMaintenanceDueAt)!}${overdue ? ' · ${app.isArabic ? 'متأخر' : 'overdue'}' : ''}', overdue, divider: true)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: PwtColors.hairline))),
            child: Row(
              children: [
                Expanded(child: PwtButton(label: s['requestMaintenance']!, variant: overdue ? PwtButtonVariant.primary : PwtButtonVariant.ghost, size: PwtButtonSize.sm, icon: PwtIcons.wrench, onPressed: onMaintenance)),
                if (isRent) ...[
                  const SizedBox(width: 8),
                  Expanded(child: PwtButton(label: s['payNow']!, variant: PwtButtonVariant.soft, size: PwtButtonSize.sm, icon: PwtIcons.card)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _svc(String label, String value, bool overdue, {bool divider = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(border: divider ? const Border(left: BorderSide(color: PwtColors.hairline)) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: PwtType.eyebrow().copyWith(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(value, style: PwtType.label(color: overdue ? PwtColors.error : PwtColors.textPri, weight: FontWeight.w600).copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Requests ───
class BusinessRequestsScreen extends StatefulWidget {
  const BusinessRequestsScreen({super.key, required this.user, required this.onProfile, required this.onSchedule});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback onSchedule;

  @override
  State<BusinessRequestsScreen> createState() => _BusinessRequestsScreenState();
}

class _BusinessRequestsScreenState extends State<BusinessRequestsScreen> {
  List<MaintenanceRequestModel> _requests = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  PaginationModel? _pagination;
  String? _error;

  /// Called by the shell when this tab is reselected — re-fetches only if
  /// the last attempt failed.
  void retryIfFailed() {
    if (_error != null) _load();
  }

  /// Called by the shell right after a new maintenance request is
  /// submitted, so the freshly-created request shows up in the list.
  void reload() => _load();

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

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
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
                  width: 110,
                  height: 110,
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
                const SizedBox(height: 24),
                if (_error != null)
                  PwtButton(label: s['retry']!, full: true, onPressed: () => _load())
                else
                  PwtButton(label: s['scheduleMaintenance']!, full: true, icon: PwtIcons.plus, onPressed: widget.onSchedule),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_requests.length} ${s['upcoming']!.toLowerCase()}', style: PwtType.caption().copyWith(fontSize: 13)),
                    PwtButton(label: s['scheduleMaintenance']!, variant: PwtButtonVariant.soft, size: PwtButtonSize.sm, icon: PwtIcons.plus, onPressed: widget.onSchedule),
                  ],
                ),
                const SizedBox(height: 12),
                for (final req in _requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RequestCard(request: req),
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
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final MaintenanceRequestModel request;

  static const _issueLabels = {
    'filter_change': 'Filter Change',
    'leak': 'Leak',
    'noise': 'Noise',
    'low_pressure': 'Low Pressure',
    'water_quality': 'Water Quality',
    'error_code': 'Error Code',
    'installation_fix': 'Installation Fix',
    'other': 'Other',
  };

  static const _slotLabels = {
    'morning':   'Morning (8AM – 12PM)',
    'afternoon': 'Afternoon (12PM – 4PM)',
    'evening':   'Evening (4PM – 7PM)',
  };

  Color _statusColor(String st) => switch (st) {
    'pending'     => PwtColors.warning,
    'scheduled'   => PwtColors.brand,
    'in_progress' => PwtColors.brand,
    'completed'   => PwtColors.success,
    _             => PwtColors.textSec,
  };

  String _statusLabel(String st) => switch (st) {
    'pending'     => 'Pending',
    'scheduled'   => 'Scheduled',
    'in_progress' => 'In Progress',
    'completed'   => 'Completed',
    'cancelled'   => 'Cancelled',
    _             => st,
  };

  @override
  Widget build(BuildContext context) {
    final r = request;
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
                Text(_issueLabels[r.issueType] ?? r.issueType, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13)),
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

// ─── Orders ───
class BusinessOrdersScreen extends StatefulWidget {
  const BusinessOrdersScreen({super.key, required this.user, required this.onProfile, this.onBrowse});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback? onBrowse;

  @override
  State<BusinessOrdersScreen> createState() => _BusinessOrdersScreenState();
}

class _BusinessOrdersScreenState extends State<BusinessOrdersScreen> {
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
        if (append) {
          _orders = [..._orders, ...res.data!.items];
        } else {
          _orders = res.data!.items;
        }
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
    'confirmed' => PwtColors.brand,
    'scheduled' => PwtColors.brand,
    'completed' => PwtColors.success,
    'cancelled' => PwtColors.error,
    _           => PwtColors.textSec,
  };

  String _statusLabel(String st) => switch (st) {
    'pending'   => 'Pending',
    'confirmed' => 'Confirmed',
    'scheduled' => 'Scheduled',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    _           => st,
  };

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
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
              Eyebrow(context.watch<AppState>().isArabic ? 'طلبيات شركتك' : 'Company orders'),
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
        else
          if (trueEmpty)
            OrdersEmptyState(onBrowse: widget.onBrowse ?? () {})
          else
          if (_orders.isEmpty)
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
                      PwtButton(
                        label: 'Load more',
                        variant: PwtButtonVariant.soft,
                        full: true,
                        onPressed: _loadMore,
                      ),
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
              Pill(label: _statusLabel(o.status), color: _statusColor(o.status), dot: true),
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
                _MorePill('+${o.remainingItemsCount}'),
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

class _MorePill extends StatelessWidget {
  const _MorePill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: PwtColors.brandTint, borderRadius: BorderRadius.circular(999)),
    child: Text(text, style: PwtType.mono(size: 11, color: PwtColors.brand, weight: FontWeight.w700)),
  );
}

// ─── Empty fleet ───
class _BusinessEmpty extends StatelessWidget {
  const _BusinessEmpty({required this.user, required this.onProfile, required this.onBrowse});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context.watch<AppState>().lang);
    return ListView(
      children: [
        AppHeader(user: user, onProfile: onProfile),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Pill(label: s['business']!),
              const SizedBox(width: 10),
              Expanded(child: Text(user.company!.name, overflow: TextOverflow.ellipsis, style: PwtType.caption().copyWith(fontSize: 12))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DevicesEmptyState(business: true, onBrowse: onBrowse),
      ],
    );
  }
}

// ═══════════════ SCHEDULE MAINTENANCE (multi-step) ═══════════════
class ScheduleMaintenanceScreen extends StatefulWidget {
  const ScheduleMaintenanceScreen({super.key, this.presetMachines = const []});
  final List<MachineModel> presetMachines;

  @override
  State<ScheduleMaintenanceScreen> createState() => _ScheduleMaintenanceScreenState();
}

class _ScheduleMaintenanceScreenState extends State<ScheduleMaintenanceScreen> {
  late String _step;
  List<MachineModel> _allMachines = [];
  bool _loadingMachines = false;
  bool _loadingMoreMachines = false;
  int _machinesPage = 1;
  PaginationModel? _machinesPagination;
  String? _machinesError;
  MachineModel? _selectedMachine;
  DateTime? _selectedDate;
  int _slot = 0;
  final _notes = TextEditingController();
  bool _submitting = false;

  static const _slots = ['Morning (8AM – 12PM)', 'Afternoon (12PM – 4PM)', 'Evening (4PM – 7PM)'];
  static const _slotTimes = ['morning', 'afternoon', 'evening'];
  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _issueTypes = ['filter_change', 'leak', 'noise', 'low_pressure', 'water_quality', 'error_code', 'installation_fix', 'other'];
  static const _issueLabels = {'filter_change': 'Filter Change', 'leak': 'Leak', 'noise': 'Noise', 'low_pressure': 'Low Pressure', 'water_quality': 'Water Quality', 'error_code': 'Error Code', 'installation_fix': 'Installation Fix', 'other': 'Other'};
  String _issueType = 'filter_change';

  @override
  void initState() {
    super.initState();
    _selectedMachine = widget.presetMachines.isNotEmpty ? widget.presetMachines.first : null;
    _step = _selectedMachine != null ? 'when' : 'select';
    if (_step == 'select') _loadMachines();
    _notes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
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
        _allMachines = append ? [..._allMachines, ...res.data!.items] : res.data!.items;
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

  String _fmtDisplay(DateTime d) {
    return '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';
  }

  String _fmtApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_selectedMachine == null || _selectedDate == null) return;
    setState(() => _submitting = true);
    final m = _selectedMachine!;
    final res = await submitMaintenanceRequest(
      machineId: m.id,
      issueType: _issueType,
      description: _notes.text.trim().isEmpty ? '' : _notes.text.trim(),
      preferredDate: _fmtApi(_selectedDate!),
      preferredTime: _slotTimes[_slot],
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (res.success) {
      setState(() => _step = 'success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Request failed'), backgroundColor: PwtColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final ar = app.isArabic;

    return DetailScaffold(
      title: s['scheduleMaintenance'],
      onBack: _step == 'when' && widget.presetMachines.isEmpty
          ? () => setState(() => _step = 'select')
          : () => Navigator.pop(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (_step == 'select') ...[
            Text(s['selectDevices']!, style: PwtType.title().copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(s['selectDevicesSub']!, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
            const SizedBox(height: 14),
            if (_loadingMachines)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand),
              ))
            else if (_allMachines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _machinesError != null ? PwtColors.error.withValues(alpha: 0.1) : PwtColors.brandTint,
                        shape: BoxShape.circle,
                        border: Border.all(color: _machinesError != null ? PwtColors.error : PwtColors.brandBorder),
                      ),
                      child: Icon(_machinesError != null ? PwtIcons.warn : PwtIcons.drop, size: 36, color: _machinesError != null ? PwtColors.error : PwtColors.brand),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _machinesError != null ? s['devicesLoadError']! : s['noDevicesYet']!,
                      style: PwtType.title().copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _machinesError != null ? s['devicesLoadErrorSub']! : s['noDevicesSub']!,
                      textAlign: TextAlign.center,
                      style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13),
                    ),
                    if (_machinesError != null) ...[
                      const SizedBox(height: 18),
                      PwtButton(label: s['retry']!, variant: PwtButtonVariant.soft, onPressed: () => _loadMachines()),
                    ],
                  ],
                ),
              )
            else
              for (final m in _allMachines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _deviceCheck(m, _selectedMachine == m, () => setState(() => _selectedMachine = m)),
                ),
            if (!_loadingMachines && _allMachines.isNotEmpty) ...[
              if (_loadingMoreMachines)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)),
                )
              else if (_machinesPagination != null && _machinesPage < (_machinesPagination!.lastPage ?? 1))
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: PwtButton(label: 'Load more', variant: PwtButtonVariant.soft, full: true, onPressed: () => _loadMachines(page: _machinesPage + 1, append: true)),
                ),
            ],
          ],
          if (_step == 'when') ...[
            Text(s['pickDate']!, style: PwtType.title().copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(_selectedMachine?.displayName ?? _selectedMachine?.product.name ?? '', style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13)),
            const SizedBox(height: 20),
            // ── date picker ──
            Eyebrow(ar ? 'التاريخ المفضّل' : 'Preferred date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: PwtColors.surface,
                  border: Border.all(color: _selectedDate != null ? PwtColors.brand : PwtColors.hairline2, width: 1.5),
                  borderRadius: BorderRadius.circular(PwtRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(PwtIcons.cal, size: 18, color: _selectedDate != null ? PwtColors.brand : PwtColors.textTer),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null
                          ? (ar ? 'اختر تاريخاً' : 'Select a date')
                          : _fmtDisplay(_selectedDate!),
                      style: PwtType.body(color: _selectedDate != null ? PwtColors.textPri : PwtColors.textTer),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── time slot ──
            Eyebrow(ar ? 'الوقت المناسب' : 'Time slot'),
            const SizedBox(height: 10),
            Column(
              children: [
                for (int i = 0; i < _slots.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _slotChip(i, ar),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // ── issue type ──
            Eyebrow(ar ? 'نوع المشكلة' : 'Issue type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _issueType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(PwtRadius.md), borderSide: const BorderSide(color: PwtColors.hairline2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(PwtRadius.md), borderSide: const BorderSide(color: PwtColors.brand, width: 1.5)),
              ),
              items: _issueTypes.map((t) => DropdownMenuItem(
                value: t,
                child: Text(_issueLabels[t]!, style: PwtType.body()),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _issueType = v); },
            ),
            const SizedBox(height: 20),
            // ── notes ──
            Eyebrow(ar ? 'ملاحظات' : 'Notes'),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: ar ? 'تعليمات الوصول أو معلومات التواصل…' : 'Access instructions, on-site contact…',
                hintStyle: PwtType.body(color: PwtColors.textTer),
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(PwtRadius.md), borderSide: const BorderSide(color: PwtColors.hairline2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(PwtRadius.md), borderSide: const BorderSide(color: PwtColors.brand, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            // ── selected devices ──
            if (_selectedMachine != null)
              Section(
                title: s['devicesLabel']!,
                child: PwtCard(
                  padding: EdgeInsets.zero,
                  child: ListRow(
                    leading: PwtIcons.drop,
                    title: _selectedMachine!.product.name,
                    sub: _selectedMachine!.displayName ?? (_selectedMachine!.publicId.isNotEmpty ? _selectedMachine!.publicId : _selectedMachine!.serialNumber),
                    last: true,
                  ),
                ),
              ),
          ],
          if (_step == 'success')
            SuccessView(
              title: s['scheduledTitle']!,
              body: s['scheduledBody']!,
              accent: PwtColors.brand,
              detail: PwtCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    ListRow(leading: PwtIcons.cal, title: _selectedDate != null ? _fmtDisplay(_selectedDate!) : '—', sub: _slots[_slot]),
                    ListRow(leading: PwtIcons.drop, title: _selectedMachine?.product.name ?? '—', sub: _selectedMachine?.displayName ?? _selectedMachine?.publicId ?? '', last: true),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomBar: switch (_step) {
        'select' => PwtButton(
            label: _selectedMachine != null ? '${s['continueLabel']} · 1' : s['continueLabel']!,
            full: true,
            disabled: _selectedMachine == null,
            onPressed: () => setState(() => _step = 'when'),
          ),
        'when' => PwtButton(
            label: _submitting ? '...' : s['scheduleVisitCta']!,
            full: true,
            disabled: _submitting || _selectedDate == null || _notes.text.trim().isEmpty,
            onPressed: (_submitting || _selectedDate == null || _notes.text.trim().isEmpty) ? null : _submit,
          ),
        _ => PwtButton(
            label: s['done']!,
            full: true,
            onPressed: () => Navigator.pop(context, true),
          ),
      },
    );
  }

  Widget _deviceCheck(MachineModel m, bool on, VoidCallback onTap) {
    final imgPath = 'assets/products/${m.product.code}.png';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? PwtColors.brandTint : PwtColors.surface,
          border: Border.all(color: on ? PwtColors.brandBorder : PwtColors.hairline, width: 1.5),
          borderRadius: BorderRadius.circular(PwtRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline2, width: 2),
              ),
              child: on ? const Center(child: SizedBox(width: 10, height: 10, child: DecoratedBox(decoration: BoxDecoration(color: PwtColors.brand, shape: BoxShape.circle)))) : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 40, height: 50,
              decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(9), border: Border.all(color: PwtColors.hairline)),
              alignment: Alignment.center,
              child: hasLocalAsset(imgPath)
                  ? Image(image: pwtImage(imgPath), height: 38, fit: BoxFit.contain)
                  : (m.product.imageUrl != null && m.product.imageUrl!.isNotEmpty
                      ? Image.network(m.product.imageUrl!, height: 38, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 20, color: PwtColors.brand))
                      : const Icon(Icons.water_drop_outlined, size: 20, color: PwtColors.brand)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (m.displayName != null && m.displayName!.isNotEmpty)
                    Text(m.displayName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 14)),
                  Text(m.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: PwtType.label(weight: m.displayName != null ? FontWeight.w400 : FontWeight.w600).copyWith(fontSize: m.displayName != null ? 13 : 14, color: m.displayName != null ? PwtColors.textSec : PwtColors.textPri)),
                  const SizedBox(height: 2),
                  Directionality(textDirection: TextDirection.ltr, child: Text(m.publicId.isNotEmpty ? m.publicId : m.serialNumber, style: PwtType.mono(size: 11.5, color: PwtColors.textTer))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotChip(int i, bool ar) {
    final on = i == _slot;
    return GestureDetector(
      onTap: () => setState(() => _slot = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: on ? PwtColors.brandTint : PwtColors.surface,
          border: Border.all(color: on ? PwtColors.brandBorder : PwtColors.hairline, width: 1.5),
          borderRadius: BorderRadius.circular(PwtRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline2, width: 2)),
              child: on ? const Center(child: SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: PwtColors.brand, shape: BoxShape.circle)))) : null,
            ),
            const SizedBox(width: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(_slots[i], style: TextStyle(fontSize: 13.5, fontWeight: on ? FontWeight.w600 : FontWeight.w500, color: on ? PwtColors.brandDeep : PwtColors.textPri)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════ QUOTATION (view / approve / cancel) ═══════════════
class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key, required this.order, required this.onDecision});
  final Order order;
  final ValueChanged<String> onDecision;

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  String? _result; // approved | cancelled

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final o = widget.order;
    const subtotal = 8020;
    final vat = (subtotal * 0.05);
    final total = subtotal + vat;

    if (_result != null) {
      return DetailScaffold(
        title: s['viewQuote'],
        body: ListView(
          children: [
            SuccessView(
              title: _result == 'approved' ? s['quoteApproved']! : s['cancelledStatus']!,
              body: _result == 'approved'
                  ? (app.isArabic ? 'سيتواصل فريقنا لتحديد موعد التركيب.' : 'Our team will reach out to arrange installation.')
                  : (app.isArabic ? 'تم سحب طلب العرض.' : 'Your quotation request has been withdrawn.'),
              icon: _result == 'approved' ? PwtIcons.check : PwtIcons.close,
              accent: _result == 'approved' ? PwtColors.success : PwtColors.textSec,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: PwtButton(label: s['done']!, full: true, onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      );
    }

    return DetailScaffold(
      title: s['viewQuote'],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PwtCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(textDirection: TextDirection.ltr, child: Text(o.id, style: PwtType.mono(size: 11, color: PwtColors.brand, weight: FontWeight.w600))),
                      const SizedBox(height: 4),
                      Text(o.items, style: PwtType.subtitle().copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${s['placed']} ${o.date}', style: PwtType.caption().copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Pill(label: s['quotationReceived']!, color: PwtColors.info, dot: true),
              ],
            ),
          ),
          Section(
            title: s['orderSummary']!,
            child: PwtCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PwtColors.hairline))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('1× ${o.items}', style: PwtType.label().copyWith(fontSize: 13.5))),
                        _money(subtotal),
                      ],
                    ),
                  ),
                  SummaryRow(label: s['subtotal']!, value: _money(subtotal, c: PwtColors.textSec)),
                  SummaryRow(label: s['vat']!, value: _money(vat, c: PwtColors.textSec)),
                  SummaryRow(label: s['total']!, bold: true, last: true, value: _money(total, c: PwtColors.textPri)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(app.isArabic ? 'يشمل التركيب وأول 3 أشهر إيجار' : 'Incl. installation + first 3 months rental', style: PwtType.caption().copyWith(fontSize: 12)),
          ),
        ],
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PwtButton(
            label: s['approveQuote']!,
            full: true,
            icon: PwtIcons.check,
            onPressed: () {
              widget.onDecision('approved');
              setState(() => _result = 'approved');
            },
          ),
          const SizedBox(height: 10),
          PwtButton(
            label: s['cancelQuote']!,
            variant: PwtButtonVariant.ghost,
            full: true,
            icon: PwtIcons.close,
            onPressed: () async {
              final ok = await showConfirmSheet(
                context,
                title: s['cancelConfirmTitle']!,
                body: s['cancelConfirmBody']!,
                keepLabel: s['keepIt']!,
                confirmLabel: s['yesCancel']!,
              );
              if (ok) {
                widget.onDecision('cancelled');
                setState(() => _result = 'cancelled');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _money(num v, {Color c = PwtColors.textPri}) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [Dirham(size: 11, color: c), const SizedBox(width: 3), Text(_fmt(v), style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 14))],
      );
}

// ═══════════════ REQUEST RFQ ═══════════════
class RequestRfqScreen extends StatefulWidget {
  const RequestRfqScreen({super.key, this.preselectedProduct});
  final ProductModel? preselectedProduct;

  @override
  State<RequestRfqScreen> createState() => _RequestRfqScreenState();
}

class _RequestRfqScreenState extends State<RequestRfqScreen> {
  final _companyName     = TextEditingController();
  final _companyEmail    = TextEditingController();
  final _contactName     = TextEditingController();
  final _jobTitle        = TextEditingController();
  final _businessEmail   = TextEditingController();
  final _phone           = TextEditingController();
  final _totalQty        = TextEditingController();
  final _requiredBy      = TextEditingController();
  final _installLocation = TextEditingController();
  final _notes           = TextEditingController();

  String _phoneCc = '+971';
  String _phoneIso = 'AE';
  bool _phoneLibReady = false;
  List<CountryModel> _countries = [];

  List<ProductModel> _products = [];
  bool _loadingProducts = true;
  int _page = 1;
  int _totalPages = 1;
  final _searchCtrl = TextEditingController();
  final Set<int> _pickedIds = {};

  bool _submitting = false;
  String? _error;
  bool _submitted = false;
  int? _submittedId;

  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final user = web.AppState.instance.user;
    if (user?.companyName?.isNotEmpty == true) _companyName.text = user!.companyName!;
    if (user?.email?.isNotEmpty == true) _companyEmail.text = user!.email!;
    if (user?.phoneCountryCode?.isNotEmpty == true) _phoneCc = user!.phoneCountryCode!;
    if (user?.phone?.isNotEmpty == true) {
      final raw = user!.phone!;
      _phone.text = raw.startsWith(_phoneCc) ? raw.substring(_phoneCc.length).trim() : raw;
    }
    if (widget.preselectedProduct?.id != null) {
      _pickedIds.add(widget.preselectedProduct!.id!);
    }
    _fetchProducts();
    _ensurePhoneLib();
    getCountries().then((res) {
      if (!mounted) return;
      if (res.success && res.data != null) {
        setState(() {
          _countries = res.data!.where((c) => (c.phoneCode ?? '').isNotEmpty).toList();
          final match = _countries.firstWhere((c) => c.phoneCode == _phoneCc, orElse: () => CountryModel());
          if (match.code != null) _phoneIso = match.code!.toUpperCase();
        });
      }
    });
  }

  Future<void> _ensurePhoneLib() async {
    if (_phoneLibReady) return;
    try {
      await init().timeout(const Duration(seconds: 5));
      _phoneLibReady = true;
    } catch (_) {
      // The phone-format library loads a script from a third-party CDN; if
      // that's unreachable, skip client-side validation rather than block
      // the form — the backend still validates the number.
    }
  }

  @override
  void dispose() {
    _companyName.dispose();
    _companyEmail.dispose();
    _contactName.dispose();
    _jobTitle.dispose();
    _businessEmail.dispose();
    _phone.dispose();
    _totalQty.dispose();
    _requiredBy.dispose();
    _installLocation.dispose();
    _notes.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({int page = 1}) async {
    setState(() { _loadingProducts = true; _page = page; });
    final res = await getProducts(
      page: page,
      perPage: 10,
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
    if (!mounted) return;
    final pagination = res.data?.pagination;
    setState(() {
      _loadingProducts = false;
      if (res.success && res.data != null) {
        _products = res.data!.items;
        _totalPages = pagination?.lastPage ?? 1;
      }
    });
  }

  Future<bool> _validate() async {
    final e = <String, String?>{};
    if (_companyName.text.trim().isEmpty) e['companyName'] = 'Required';

    final email = _companyEmail.text.trim();
    if (email.isEmpty) {
      e['companyEmail'] = 'Required';
    } else if (!EmailValidator.validate(email)) {
      e['companyEmail'] = 'Please enter a valid email address.';
    }

    final phone = _phone.text.trim();
    if (phone.isEmpty) {
      e['phone'] = 'Required';
    } else {
      await _ensurePhoneLib();
      try {
        if (_phoneLibReady) await parse(phone, region: _phoneIso);
      } catch (_) {
        e['phone'] = 'Please enter a valid mobile number for the selected country.';
      }
    }

    setState(() => _fieldErrors = e);
    return e.isEmpty;
  }

  Future<void> _submit() async {
    if (!await _validate()) return;
    setState(() { _submitting = true; _error = null; });

    final res = await createRfq(
      companyName:          _companyName.text.trim(),
      email:                _companyEmail.text.trim(),
      phoneCountryCode:     _phoneCc,
      phone:                _phone.text.trim(),
      notes:                _notes.text.trim(),
      // contactName:          _contactName.text.trim(),
      // jobTitle:             _jobTitle.text.trim(),
      // businessEmail:        _businessEmail.text.trim(),
      // preferredProducts:    _pickedIds.toList(),
      // totalQuantity:        _totalQty.text.trim(),
      // requiredBy:           _requiredBy.text.trim(),
      // installationLocation: _installLocation.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.success && res.data != null) {
      setState(() { _submitted = true; _submittedId = res.data!.id; });
    } else {
      setState(() => _error = res.message ?? res.error ?? 'Failed to submit. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ar = app.isArabic;

    if (_submitted) {
      return DetailScaffold(
        title: ar ? 'تم استلام الطلب' : 'Request Received',
        body: ListView(children: [
          SuccessView(
            title: ar ? 'تم إرسال طلب عرض السعر!' : 'Quotation Request Sent!',
            body: ar
                ? 'سيتواصل فريقنا معك خلال 24 ساعة بعرض مخصص لاحتياجاتك.'
                : 'Our team will contact you within 24 hours with a custom quotation.',
            icon: PwtIcons.check,
            accent: PwtColors.success,
          ),
          // Request ID chip — commented out for now
          // if (_submittedId != null)
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          //     child: Center(
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          //         decoration: BoxDecoration(color: PwtColors.bgElev, borderRadius: BorderRadius.circular(999), border: Border.all(color: PwtColors.hairline)),
          //         child: Text('PWT-RFQ-$_submittedId', style: PwtType.mono(size: 12, color: PwtColors.brand, weight: FontWeight.w600)),
          //       ),
          //     ),
          //   ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: PwtButton(label: ar ? 'تم' : 'Done', full: true, onPressed: () => Navigator.of(context).pop()),
          ),
        ]),
      );
    }

    return DetailScaffold(
      title: ar ? 'طلب عرض سعر' : 'Request a Quotation',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Company
          Section(title: ar ? 'معلومات الشركة' : 'Company Information', child: Column(children: [
            _field(ar ? 'اسم الشركة' : 'Company name', ar ? 'شركة أكمي للمرافق' : 'Acme Facilities Ltd', _companyName, errorKey: 'companyName'),
            _field(ar ? 'البريد الإلكتروني' : 'Email', 'info@company.com', _companyEmail, errorKey: 'companyEmail', keyboardType: TextInputType.emailAddress),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ar ? 'رقم الهاتف' : 'Phone number', style: PwtType.label()),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: PwtColors.surface,
                      border: Border.all(color: _fieldErrors['phone'] != null ? PwtColors.error : PwtColors.hairline, width: 1.5),
                      borderRadius: BorderRadius.circular(PwtRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _phoneCc,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: PwtColors.textTer),
                        style: PwtType.label().copyWith(fontSize: 14),
                        items: _countries.isEmpty
                            ? [DropdownMenuItem(value: _phoneCc, child: Text(_phoneCc))]
                            : _countries.map((c) => DropdownMenuItem(
                                value: c.phoneCode!,
                                child: Text('${_rfqAppFlagFromCode(c.code)} ${c.phoneCode}'),
                              )).toList(),
                        onChanged: (v) => setState(() {
                          _phoneCc = v!;
                          final match = _countries.firstWhere((c) => c.phoneCode == v, orElse: () => CountryModel());
                          if (match.code != null) _phoneIso = match.code!.toUpperCase();
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '50 123 4567',
                        hintStyle: PwtType.body(color: PwtColors.textTer),
                        errorText: _fieldErrors['phone'],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PwtRadius.md),
                          borderSide: BorderSide(color: _fieldErrors['phone'] != null ? PwtColors.error : PwtColors.hairline2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PwtRadius.md),
                          borderSide: BorderSide(color: _fieldErrors['phone'] != null ? PwtColors.error : PwtColors.brand, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PwtRadius.md),
                          borderSide: const BorderSide(color: PwtColors.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PwtRadius.md),
                          borderSide: const BorderSide(color: PwtColors.error, width: 1.5),
                        ),
                      ),
                      onChanged: (_) => setState(() => _fieldErrors.remove('phone')),
                    ),
                  ),
                ]),
              ]),
            ),
            _field(ar ? 'ملاحظات' : 'Notes / comments', ar ? 'المنتجات، الكميات، الموعد المطلوب، العنوان…' : 'Products, quantities, required within 1 month, address…', _notes, lines: 4),
            // Trade license upload — coming soon
          ])),

          // Step 2 — Contact Person (commented out for now)
          // Section(title: ar ? 'جهة الاتصال' : 'Contact Person', child: Column(children: [
          //   _field(ar ? 'الاسم الكامل' : 'Full name', ..., _contactName),
          //   _field(ar ? 'المسمى الوظيفي' : 'Job title', ..., _jobTitle),
          //   _field(ar ? 'البريد الإلكتروني للعمل' : 'Business email', ..., _businessEmail),
          // ])),

          // Step 3 — Your Requirements (commented out for now)
          // Section(title: ar ? 'متطلباتك' : 'Your Requirements', child: Column(children: [
          //   ... product picker, pagination, total qty, required by, installation location ...
          // ])),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PwtBanner(variant: BannerVariant.error, body: _error!),
            ),
        ],
      ),
      bottomBar: PwtButton(
        label: _submitting ? (ar ? 'جارٍ الإرسال…' : 'Submitting…') : (ar ? 'إرسال الطلب' : 'Submit Request'),
        full: true,
        icon: PwtIcons.arrow,
        onPressed: _submitting ? null : _submit,
      ),
    );
  }

  Widget _productTile(ProductModel p) {
    final on = _pickedIds.contains(p.id);
    return GestureDetector(
      onTap: () => setState(() => on ? _pickedIds.remove(p.id) : _pickedIds.add(p.id!)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? PwtColors.brandTint : PwtColors.surface,
          borderRadius: BorderRadius.circular(PwtRadius.card),
          border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline, width: on ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: PwtColors.surface2, borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(5),
            child: p.primaryImageUrl != null
                ? Image.network(p.primaryImageUrl!, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(PwtIcons.drop, size: 22, color: PwtColors.brandBorder))
                : const Icon(PwtIcons.drop, size: 22, color: PwtColors.brandBorder),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.code ?? p.name ?? '', style: PwtType.label(), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (p.shortDescription != null)
              Text(p.shortDescription!, style: PwtType.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Icon(on ? PwtIcons.check : Icons.circle_outlined, size: 18, color: on ? PwtColors.brand : PwtColors.textTer),
        ]),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl, {int lines = 1, String? errorKey, TextInputType? keyboardType}) {
    final hasError = errorKey != null && _fieldErrors[errorKey] != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: PwtType.label()),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: lines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: PwtType.body(color: PwtColors.textTer),
            errorText: errorKey != null ? _fieldErrors[errorKey] : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PwtRadius.md),
              borderSide: BorderSide(color: hasError ? PwtColors.error : PwtColors.hairline2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PwtRadius.md),
              borderSide: BorderSide(color: hasError ? PwtColors.error : PwtColors.brand, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PwtRadius.md),
              borderSide: const BorderSide(color: PwtColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PwtRadius.md),
              borderSide: const BorderSide(color: PwtColors.error, width: 1.5),
            ),
          ),
          onChanged: errorKey != null ? (_) => setState(() => _fieldErrors.remove(errorKey)) : null,
        ),
      ]),
    );
  }
}

String _fmt(num v) => v.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

String _rfqAppFlagFromCode(String? code) {
  if (code == null || code.length != 2) return '🌐';
  final a = code.toUpperCase().codeUnitAt(0) - 65 + 0x1F1E6;
  final b = code.toUpperCase().codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCodes([a, b]);
}
