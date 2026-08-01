import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/dash_kit.dart';
import '../widgets/empty_states.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Backend/Orders/get_orders.dart';
import '../../Backend/Orders/get_order_tracking.dart';
import '../../Models/Orders/order_tracking.dart';

String _fmt(String? iso) {
  if (iso == null) return '—';
  try {
    final dt = DateTime.parse(iso);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  } catch (_) { return iso; }
}

String _shortId(String publicId) =>
    '#${publicId.length >= 8 ? publicId.substring(0, 8).toUpperCase() : publicId.toUpperCase()}';

bool _ongoing(String s)   => const ['pending', 'confirmed', 'scheduled'].contains(s);
bool _completed(String s) => s == 'completed';
bool _cancelled(String s) => s == 'cancelled';

List<TlStep> _buildTrackingSteps(OrderTrackingModel t) {
  final steps = t.milestones
      .map((m) => TlStep(m.label, _fmt(m.occurredAt), done: true))
      .toList();
  if (steps.isEmpty) {
    steps.add(const TlStep('Order Placed', '—', done: true));
  }
  final finished = t.status == 'completed' || t.status == 'cancelled';
  if (!finished && t.nextStep != null) {
    final eta = t.nextStep!.estimatedAt != null
        ? _fmt(t.nextStep!.estimatedAt)
        : t.estimatedDeliveryWindow ?? 'Upcoming';
    steps.add(TlStep(t.nextStep!.label, eta, pending: true));
  }
  return steps;
}

class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});
  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen> {
  int _tab = 0;
  static const _tabs = ['All Orders', 'Ongoing', 'Completed', 'Cancelled'];
  static const _tabStatuses = <String?>[null, 'pending', 'completed', 'cancelled'];

  bool _loading = false;
  String? _error;
  List<OrderModel> _all = [];
  PaginationModel? _pagination;
  Map<String, dynamic>? _stats;
  int _page = 1;
  String? _currentStatus;
  final _pageCache = <String, List<OrderModel>>{};

  // tracking panel state
  int? _selectedId;
  bool _detailLoading = false;
  OrderTrackingModel? _selectedTracking;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1, String? status}) async {
    final cacheKey = '${status ?? ''}:$page';
    if (_pageCache.containsKey(cacheKey)) {
      setState(() { _all = _pageCache[cacheKey]!; _page = page; _currentStatus = status; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    final res = await getOrders(page: page, status: status);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _pageCache[cacheKey] = res.data!.items;
      setState(() {
        _loading = false;
        _all = res.data!.items;
        _pagination = res.data!.pagination;
        _stats = res.data!.meta?['stats'] as Map<String, dynamic>?;
        _page = page;
        _currentStatus = status;
        _selectedId = null;
        _selectedTracking = null;
      });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load orders.'; });
    }
  }

  Future<void> _selectOrder(int id) async {
    if (_selectedId == id) {
      setState(() { _selectedId = null; _selectedTracking = null; });
      return;
    }
    setState(() { _selectedId = id; _detailLoading = true; _selectedTracking = null; });
    final res = await getOrderTracking(id);
    if (!mounted) return;
    setState(() { _detailLoading = false; _selectedTracking = res.data; });
  }

  String _statVal(String key, String sub) {
    final s = _stats?[key] as Map<String, dynamic>?;
    return s?[sub]?.toString() ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final openPos      = _statVal('open_pos', 'total');
    final awaitingAppr = _statVal('open_pos', 'awaiting_approval');
    final unitsTotal   = _statVal('units_on_order', 'total');
    final unitsSites   = _statVal('units_on_order', 'sites');
    final quotations   = _statVal('quotations', 'total');
    final quotPending  = _statVal('quotations', 'pending_review');
    final valueMap     = _stats?['value_on_order'] as Map<String, dynamic>?;
    final valueAmt     = valueMap?['amount']?.toString();
    final valueCur     = valueMap?['currency']?.toString() ?? 'AED';
    final valueStr     = valueAmt != null
        ? '$valueCur ${double.tryParse(valueAmt)?.toStringAsFixed(0) ?? valueAmt}'
        : '—';

    return DashScaffold(
      active: 'orders',
      isCompany: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DashCrumb(const ['Dashboard', 'Orders'], routes: const ['/companyDashboard', null]),
          const SizedBox(height: 6),
          PageHead(
            title: 'Orders',
            subtitle: 'Your purchase orders and quotations, newest first',
            action: NewOrderButton(label: 'New Bulk Order', onTap: () => Navigator.of(context).pushNamed('/rfq')),
          ),
          KpiRow(cards: [
            KpiFeatureCard(label: 'Open POs', value: openPos, sub: '$awaitingAppr awaiting approval', image: 'assets/images/order.png'),
            KpiCard(label: 'Units on Order', value: unitsTotal, sub: 'across $unitsSites sites', numSize: 30),
            KpiCard(label: 'Quotations', value: quotations, sub: '$quotPending pending review', numSize: 30),
            KpiCard(label: 'Value on Order', value: valueStr, sub: 'Net 30 terms', numSize: 22),
          ]),
          const SizedBox(height: 18),
          // tabs
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: const Color(0xFFEEF2F9), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(_tabs.length, (i) {
              final on = _tab == i;
              return GestureDetector(
                onTap: () { _pageCache.clear(); setState(() => _tab = i); _load(status: _tabStatuses[i]); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 6 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: on ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: on ? [BoxShadow(color: const Color(0xFF0F1E50).withOpacity(.08), blurRadius: 6, offset: const Offset(0, 2))] : null,
                  ),
                  child: Text(_tabs[i], style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: on ? AppColors.blue700 : AppColors.ink500)),
                ),
              );
            })),
          ),
          const SizedBox(height: 20),
          // orders table card
          DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DCardHead('Orders',
                    trailing: Text('Sorted by date · newest first',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink500))),
                if (_loading)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                else if (_error != null)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(_error!, style: AppText.muted.copyWith(color: AppColors.danger)))
                else if (_all.isEmpty && _currentStatus == null)
                  SizedBox(width: double.infinity, child: Center(child: OrdersEmptyState(onBrowse: () => Navigator.of(context).pushNamed('/rfq'))))
                else if (_all.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('No orders in this category.', style: AppText.muted)))
                else
                  _table(_all),
                if (!_loading && (_pagination?.lastPage ?? 1) > 1) ...[
                  const SizedBox(height: 16),
                  _pagRow(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          // tracking + support cards
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 1000;
            final left  = _trackingCard();
            final right = _supportCard();
            if (wide) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 16, child: left),
                const SizedBox(width: 18),
                Expanded(flex: 10, child: right),
              ]);
            }
            return Column(mainAxisSize: MainAxisSize.min, children: [left, const SizedBox(height: 18), right]);
          }),
        ],
      ),
    );
  }

  // ── table ─────────────────────────────────────────────────────
  static const _cols = [
    _Col('PRODUCT',   0,   3),
    _Col('ORDER ID',  140, 0),
    _Col('QTY',       60,  0),
    _Col('TOTAL',     120, 0),
    _Col('DATE',      110, 0),
    _Col('STATUS',    140, 0),
    _Col('',          80,  0),
  ];

  Widget _table(List<OrderModel> rows) {
    return LayoutBuilder(builder: (ctx, c) {
      if (c.maxWidth < 720) {
        return Column(mainAxisSize: MainAxisSize.min, children: rows.map((o) => _mobileCard(ctx, o)).toList());
      }
      const minW = 980.0;
      final tbl = SizedBox(
        width: c.maxWidth < minW ? minW : c.maxWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(
            children: _cols.map((col) => col.flex > 0
                ? Expanded(flex: col.flex, child: _th(col.label))
                : SizedBox(width: col.width, child: _th(col.label))).toList(),
          )),
          Container(height: 1, color: AppColors.line),
          ...rows.map((o) => _dataRow(ctx, o)),
        ]),
      );
      return c.maxWidth < minW ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: tbl) : tbl;
    });
  }

  Widget _th(String t) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.ink400));

  Widget _cell(int i, Widget child) {
    final col = _cols[i];
    return col.flex > 0 ? Expanded(flex: col.flex, child: child) : SizedBox(width: col.width, child: child);
  }

  Widget _dataRow(BuildContext ctx, OrderModel o) {
    final selected = _selectedId == o.id;
    return InkWell(
      onTap: () => _selectOrder(o.id),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF4FF) : null,
          border: const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _cell(0, _prodCell(o)),
          _cell(1, Text(o.displayName ?? _shortId(o.publicId), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900))),
          _cell(2, Text('${o.itemsCount}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900))),
          _cell(3, Text('${o.currency} ${o.totalAmount}', style: const TextStyle(fontSize: 13.5, color: AppColors.ink700))),
          _cell(4, Text(_fmt(o.placedAt), style: const TextStyle(fontSize: 13.5, color: AppColors.ink700))),
          _cell(5, Align(alignment: Alignment.centerLeft, child: StBadge(o.status))),
          _cell(6, Align(alignment: Alignment.centerRight, child:
            DBtn('View', kind: DBtnKind.ghost, small: true,
              onTap: () => Navigator.of(ctx).pushNamed('/orderDetail', arguments: o.id)),
          )),
        ]),
      ),
    );
  }

  Widget _prodCell(OrderModel o) {
    final name = o.firstProductName ?? 'Order #${o.id}';
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.water_drop_outlined, size: 20, color: AppColors.blue200),
      ),
      const SizedBox(width: 10),
      Expanded(child: Row(children: [
        Flexible(child: Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900), maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (o.remainingItemsCount > 0) ...[
          const SizedBox(width: 6),
          _MorePill('+${o.remainingItemsCount} product${o.remainingItemsCount == 1 ? '' : 's'}'),
        ],
      ])),
    ]);
  }

  Widget _mobileCard(BuildContext ctx, OrderModel o) {
    final selected = _selectedId == o.id;
    Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(k, style: const TextStyle(fontSize: 12, color: AppColors.ink400, fontWeight: FontWeight.w600)),
        Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink900)),
      ]),
    );
    return GestureDetector(
      onTap: () => _selectOrder(o.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF4FF) : null,
          border: Border.all(color: selected ? AppColors.blue200 : AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _prodCell(o),
          const SizedBox(height: 12),
          kv('Order ID', _shortId(o.publicId)),
          kv('Qty', '${o.itemsCount}'),
          kv('Total', '${o.currency} ${o.totalAmount}'),
          kv('Date', _fmt(o.placedAt)),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: StBadge(o.status)),
          const SizedBox(height: 12),
          DBtn('View', kind: DBtnKind.ghost, small: true,
            onTap: () => Navigator.of(ctx).pushNamed('/orderDetail', arguments: o.id)),
        ]),
      ),
    );
  }

  Widget _pagRow() {
    final cur  = _page;
    final last = _pagination?.lastPage ?? 1;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      DBtn('Previous', kind: DBtnKind.outline, small: true, onTap: cur > 1 ? () => _load(page: cur - 1, status: _currentStatus) : null),
      const SizedBox(width: 16),
      Text('Page $cur of $last', style: const TextStyle(fontSize: 13, color: AppColors.ink600)),
      const SizedBox(width: 16),
      DBtn('Next', kind: DBtnKind.outline, small: true, onTap: cur < last ? () => _load(page: cur + 1, status: _currentStatus) : null),
    ]);
  }

  // ── tracking card (below table) ────────────────────────────────
  Widget _trackingCard() {
    final selOrder = _selectedId != null && _all.any((o) => o.id == _selectedId)
        ? _all.firstWhere((o) => o.id == _selectedId)
        : null;
    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        DCardHead(
          selOrder != null
              ? 'Delivery & Install Schedule · ${selOrder.displayName??_shortId(selOrder.publicId)}'
              : 'Delivery & Install Schedule',
          trailing: _selectedTracking != null ? StBadge(_selectedTracking!.status) : null,
        ),
        if (_selectedId == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(children: const [
              Icon(Icons.touch_app_outlined, size: 16, color: AppColors.ink400),
              SizedBox(width: 8),
              Text('Select an order row to view its tracking.', style: TextStyle(fontSize: 13.5, color: AppColors.ink400)),
            ]),
          )
        else if (_detailLoading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_selectedTracking != null)
          DashTimeline(_buildTrackingSteps(_selectedTracking!))
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Could not load tracking info.', style: AppText.muted.copyWith(color: AppColors.danger)),
          ),
      ]),
    );
  }

  // ── support card ────────────────────────────────────────────────
  Widget _supportCard() {
    return DCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        const DCardHead('Bulk Order Support'),
        Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.person_outline, color: AppColors.blue700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: const [
            Text('James Whitfield · Account Manager', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink900)),
            SizedBox(height: 2),
            Text('Direct: 0800 123 4570 · james.w@pwt.com', style: TextStyle(fontSize: 12.5, color: AppColors.ink500)),
          ])),
        ]),
        const SizedBox(height: 16),
        DBtn('Request a Quotation', fullWidth: true, onTap: () => Navigator.of(context).pushNamed('/rfq')),
        const SizedBox(height: 10),
        DBtn('Download Account Statement', kind: DBtnKind.outline, fullWidth: true,
            onTap: () => Navigator.of(context).pushReplacementNamed('/invoices')),
      ]),
    );
  }
}

class _MorePill extends StatelessWidget {
  final String text;
  const _MorePill(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: const Color(0xFFE6EFFF), borderRadius: BorderRadius.circular(999)),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue700)),
  );
}

class _Col {
  final String label;
  final double width;
  final int flex;
  const _Col(this.label, this.width, this.flex);
}
