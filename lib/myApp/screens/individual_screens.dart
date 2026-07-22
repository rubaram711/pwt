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
import '../widgets/pwt_icons.dart';
import 'account_screens.dart';
import 'cart_screen.dart';
import 'overlays.dart';
import 'product_detail_screen.dart';
import '../../myWeb2/state/app_state.dart' as web;
import '../../Backend/Machines/get_machines.dart';
import '../../Backend/Maintenance/get_maintenance_requests.dart';
import '../../Backend/Categories/get_categories.dart';
import '../../Backend/Products/get_products.dart';
import '../../Models/category_model.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Maintenance/maintenance_request_model.dart';
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
  String _tab = 'devices';
  List<MachineModel> _machines = [];
  bool _loadingMachines = true;
  bool _loadingMoreMachines = false;
  int _machinesPage = 1;
  PaginationModel? _machinesPagination;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines({int page = 1, bool append = false}) async {
    if (append) {
      setState(() => _loadingMoreMachines = true);
    } else {
      setState(() => _loadingMachines = true);
    }
    final res = await getMachines(page: page);
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _machines = append ? [..._machines, ...res.data!.items] : res.data!.items;
        _machinesPagination = res.data!.pagination;
        _machinesPage = page;
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
      return _BrandBackdrop(child: Column(children: [
        AppHeader(user: _user, onProfile: () => _scaffoldKey.currentState?.openEndDrawer()),
        const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand))),
      ]));
    }
    if (_machines.isEmpty) {
      return _DevicesEmpty(user: _user, onProfile: () => _scaffoldKey.currentState?.openEndDrawer(), onBrowse: () => setState(() => _tab = 'products'));
    }
    return IndividualHome(
      machines: _machines,
      user: _user,
      onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: PwtColors.bg,
      endDrawer: ProfileDrawer(user: _user, onSelect: _onDrawerSelect),
      floatingActionButton: FloatingCart(onTap: () => _push(const CartScreen(role: AccountKind.individual))),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: ['devices', 'products'].indexOf(_tab),
          children: [
            _devicesTab(),
            ProductsScreen(
              user: _user,
              role: AccountKind.individual,
              onProfile: () => _scaffoldKey.currentState?.openEndDrawer(),
              onOpenProduct: (p) => _push(ProductDetailScreen(product: p, role: AccountKind.individual)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PwtBottomNav(
        active: _tab,
        onChanged: (k) {
          setState(() => _tab = k);
          if (k == 'devices') _loadMachines();
        },
        items: [
          PwtNavItem(key: 'devices', label: s['devices']!, icon: PwtIcons.drop),
          PwtNavItem(key: 'products', label: s['shop']!, icon: PwtIcons.cube),
        ],
      ),
    );
  }
}

class _BrandBackdrop extends StatelessWidget {
  const _BrandBackdrop({this.opacity = 0.18, required this.child});
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

    return _BrandBackdrop(
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
                final tint = MockData.productById(code)?.tint ?? const Color(0xFF1D4ED8);
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
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  PaginationModel? _pagination;
  int? _selectedCategoryId;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

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
      setState(() { _loading = true; _products = []; });
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

    return _BrandBackdrop(
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
                    decoration: BoxDecoration(color: PwtColors.brandTint, shape: BoxShape.circle),
                    child: const Icon(PwtIcons.cube, size: 32, color: PwtColors.brand),
                  ),
                  const SizedBox(height: 20),
                  Text(s['products']!, style: PwtType.title().copyWith(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(ar ? 'لا توجد منتجات متاحة حالياً.' : 'No products available at the moment.', textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec)),
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
class _DevicesEmpty extends StatelessWidget {
  const _DevicesEmpty({required this.user, required this.onProfile, required this.onBrowse});
  final AppUser user;
  final VoidCallback onProfile;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    return _BrandBackdrop(
      child: ListView(
        children: [
          AppHeader(user: user, onProfile: onProfile),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s['welcomeBack']!),
                const SizedBox(height: 4),
                Text('${user.name.split(' ').first} 👋', style: PwtType.headline().copyWith(fontSize: 24)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: PwtColors.brandTint, shape: BoxShape.circle),
              child: const Icon(PwtIcons.drop, size: 32, color: PwtColors.brand),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: Text(s['noDevicesYet']!, style: PwtType.title().copyWith(fontSize: 20))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(s['noDevicesSub']!, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: PwtButton(label: s['browseProducts']!, full: true, icon: PwtIcons.cube, onPressed: onBrowse),
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
      setState(() { _loading = true; _requests = []; });
    }
    final res = await getMaintenanceRequests(page: page);
    if (!mounted) return;
    setState(() {
      if (res.success && res.data != null) {
        _requests = append ? [..._requests, ...res.data!.items] : res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
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
                  decoration: BoxDecoration(color: PwtColors.brandTint, shape: BoxShape.circle, border: Border.all(color: PwtColors.brandBorder)),
                  child: const Icon(PwtIcons.wrench, size: 48, color: PwtColors.brand),
                ),
                const SizedBox(height: 22),
                Text(s['noRequestsYet']!, style: PwtType.title().copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Text(s['noRequestsSub']!, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5)),
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
