import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/dash_kit.dart';
import '../widgets/empty_states.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Backend/Orders/get_orders.dart';
import '../../Backend/Orders/get_order_details.dart';

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

// ════════════════════════════════════════════════════════════════
// Orders list
// ════════════════════════════════════════════════════════════════
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
      });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load orders.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _pagination?.total ?? _all.length;
    final rawValue = (_stats?['value_on_order'] as Map<String, dynamic>?);
    final valueAmt = rawValue?['amount']?.toString();
    final valueCur = rawValue?['currency']?.toString() ?? 'AED';
    final valueStr = valueAmt != null
        ? '$valueCur ${double.tryParse(valueAmt)?.toStringAsFixed(0) ?? valueAmt}'
        : '—';

    return DashScaffold(
      active: 'orders',
      isCompany: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashCrumb(const ['Dashboard', 'My Orders'], routes: const ['/dashboard', null]),
        const SizedBox(height: 6),
        PageHead(
          title: 'My Orders',
          subtitle: 'Track and manage all your orders in one place',
          action: NewOrderButton(label: 'New Order', onTap: () => Navigator.of(context).pushNamed('/shop')),
        ),
        KpiRow(cards: [
          KpiFeatureCard(
            label: 'Total Orders',
            value: '$total',
            link: 'View all orders',
            image: 'assets/images/order.png',
            onLink: () => setState(() => _tab = 0),
          ),
          KpiCard(label: 'Value on Order', value: valueStr, sub: 'All-time total', numSize: 20),
          KpiCard(
            label: 'Ongoing',
            value: '${_all.where((o) => _ongoing(o.status)).length}',
            sub: 'Active orders',
            numSize: 30,
          ),
          KpiCard(
            label: 'Completed',
            value: '${_all.where((o) => _completed(o.status)).length}',
            sub: 'Fulfilled orders',
            numSize: 30,
          ),
        ]),
        const SizedBox(height: 18),
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
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const DCardHead('Order History'),
          if (_loading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_error != null)
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(_error!, style: AppText.muted.copyWith(color: AppColors.danger)))
          else if (_all.isEmpty && _currentStatus == null)
            SizedBox(width: double.infinity, child: Center(child: OrdersEmptyState(onBrowse: () => Navigator.of(context).pushNamed('/shop'))))
          else if (_all.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('No orders in this category.', style: AppText.muted)))
          else
            _table(_all),
          if (!_loading && (_pagination?.lastPage ?? 1) > 1) ...[
            const SizedBox(height: 16),
            _pagRow(),
          ],
        ])),
      ]),
    );
  }

  Widget _table(List<OrderModel> rows) {
    return LayoutBuilder(builder: (ctx, c) {
      if (c.maxWidth < 720) return Column(children: rows.map((o) => _mobileCard(ctx, o)).toList());
      const minW = 860.0;
      final tbl = SizedBox(
        width: c.maxWidth < minW ? minW : c.maxWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: const [
            Expanded(flex: 3, child: _Th('PRODUCT')),
            Expanded(flex: 2, child: _Th('ORDER ID')),
            Expanded(flex: 2, child: _Th('DATE')),
            Expanded(flex: 2, child: _Th('TOTAL')),
            Expanded(flex: 2, child: _Th('STATUS')),
            SizedBox(width: 90, child: _Th('')),
          ])),
          Container(height: 1, color: AppColors.line),
          ...rows.map((o) => _dataRow(ctx, o)),
        ]),
      );
      return c.maxWidth < minW ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: tbl) : tbl;
    });
  }

  Widget _dataRow(BuildContext ctx, OrderModel o) {
    return InkWell(
      onTap: () => Navigator.of(ctx).pushNamed('/orderDetail', arguments: o.id),
      child: Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(flex: 3, child: _prodCell(o)),
          Expanded(flex: 2, child: Text(o.displayName ?? _shortId(o.publicId), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900))),
          Expanded(flex: 2, child: Text(_fmt(o.placedAt), style: const TextStyle(fontSize: 13.5, color: AppColors.ink700))),
          Expanded(flex: 2, child: Text('${o.currency} ${o.totalAmount}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: StBadge(o.status))),
          SizedBox(width: 90, child: Align(alignment: Alignment.centerRight, child:
            DBtn(
              _ongoing(o.status) ? 'Track' : 'View',
              kind: DBtnKind.outline,
              small: true,
              onTap: () => Navigator.of(ctx).pushNamed('/orderDetail', arguments: o.id),
            ),
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
    return InkWell(
      onTap: () => Navigator.of(ctx).pushNamed('/orderDetail', arguments: o.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: _prodCell(o)), StBadge(o.status)]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_shortId(o.publicId)} · ${_fmt(o.placedAt)}', style: const TextStyle(fontSize: 12.5, color: AppColors.ink500)),
            Text('${o.currency} ${o.totalAmount}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900)),
          ]),
          const SizedBox(height: 10),
          DBtn(_ongoing(o.status) ? 'Track' : 'View', kind: DBtnKind.outline, small: true,
            onTap: () => Navigator.of(ctx).pushNamed('/orderDetail', arguments: o.id)),
        ]),
      ),
    );
  }

  Widget _pagRow() {
    final cur = _page;
    final last = _pagination?.lastPage ?? 1;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      DBtn('Previous', kind: DBtnKind.outline, small: true, onTap: cur > 1 ? () => _load(page: cur - 1, status: _currentStatus) : null),
      const SizedBox(width: 16),
      Text('Page $cur of $last', style: const TextStyle(fontSize: 13, color: AppColors.ink600)),
      const SizedBox(width: 16),
      DBtn('Next', kind: DBtnKind.outline, small: true, onTap: cur < last ? () => _load(page: cur + 1, status: _currentStatus) : null),
    ]);
  }
}

class _Th extends StatelessWidget {
  final String t;
  const _Th(this.t);
  @override
  Widget build(BuildContext context) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.ink400));
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

// ════════════════════════════════════════════════════════════════
// Order detail
// ════════════════════════════════════════════════════════════════
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = true;
  String? _error;
  OrderDetailModel? _order;
  bool _idInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_idInit) {
      _idInit = true;
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id != null) {
        _fetch(id);
      } else {
        setState(() { _loading = false; _error = 'Order not found.'; });
      }
    }
  }

  Future<void> _fetch(int id) async {
    final res = await getOrderDetail(id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _loading = false; _order = res.data; });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load order.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = _order;
    final label = o != null ? (o.displayName ?? _shortId(o.publicId)) : 'Order';
    final isCompany   = AppState.instance.isCompany;
    final dashRoute   = isCompany ? '/companyDashboard' : '/dashboard';
    final ordersRoute = isCompany ? '/companyOrders'    : '/orders';
    return DashScaffold(
      active: 'orders',
      isCompany: isCompany,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashCrumb(['Dashboard', 'Orders', label], routes: [dashRoute, ordersRoute, null]),
        const SizedBox(height: 6),
        PageHead(
          title: label,
          subtitle: o != null ? 'Placed ${_fmt(o.placedAt)}' : '',
          action: DBtn('Back to Orders', kind: DBtnKind.outline, icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pushReplacementNamed(ordersRoute)),
        ),
        if (_loading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_error != null || o == null)
          DCard(child: Column(children: [
            const SizedBox(height: 10),
            Text(_error ?? 'Order not found.', style: AppText.muted.copyWith(color: AppColors.danger)),
            const SizedBox(height: 16),
            DBtn('Back to Orders', onTap: () => Navigator.of(context).pushReplacementNamed(AppState.instance.isCompany ? '/companyOrders' : '/orders')),
            const SizedBox(height: 10),
          ]))
        else
          _body(o),
      ]),
    );
  }

  Widget _body(OrderDetailModel o) {
    return LayoutBuilder(builder: (ctx, c) {
      final wide = c.maxWidth > 1000;
      final Widget main, side;
      if (_cancelled(o.status)) {
        main = _cancelledMain(o);
        side = Column(children: [_summaryCard(o), const SizedBox(height: 18), _helpCard()]);
      } else if (_completed(o.status)) {
        main = _completedMain(o);
        side = _completedSide(o);
      } else {
        main = _ongoingMain(o);
        side = _ongoingSide(o);
      }
      if (wide) {
        return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 16, child: main),
          const SizedBox(width: 18),
          Expanded(flex: 10, child: side),
        ]));
      }
      return Column(children: [main, const SizedBox(height: 18), side]);
    });
  }

  // ── ongoing ──────────────────────────────────────────
  Widget _ongoingMain(OrderDetailModel o) => Column(children: [
    DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DCardHead('Tracking · ${o.displayName ?? _shortId(o.publicId)}', trailing: StBadge(o.status)),
      DashTimeline(_trackingSteps(o)),
    ])),
    const SizedBox(height: 18),
    _itemsCard(o),
  ]);

  Widget _ongoingSide(OrderDetailModel o) => Column(children: [
    DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DCardHead('Delivery'),
      _kv('Recipient', o.customerName ?? '—'),
      _kv('Address', _addressStr(o)),
      _kv('Time Slot', _slotLabel(o.installationPreferredTime)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(11)),
        child: Row(children: const [
          Icon(Icons.local_shipping_outlined, size: 17, color: AppColors.blue700),
          SizedBox(width: 9),
          Expanded(child: Text('Free installation included on arrival.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.blue700))),
        ]),
      ),
    ])),
    const SizedBox(height: 18),
    _summaryCard(o),
    const SizedBox(height: 18),
    _helpCard(),
  ]);

  // ── completed ──────────────────────────────────────────
  Widget _completedMain(OrderDetailModel o) => Column(children: [
    DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 46, height: 46,
          decoration: BoxDecoration(color: const Color(0xFFE7F7EF), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.check_circle_outline, color: AppColors.green600, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Order completed', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink900)),
          const SizedBox(height: 3),
          Text('Completed ${_fmt(o.completedAt)}', style: const TextStyle(fontSize: 13, color: AppColors.ink500)),
        ])),
        StBadge(o.status),
      ]),
    ])),
    const SizedBox(height: 18),
    _itemsCard(o),
    const SizedBox(height: 18),
    DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DCardHead('Fulfilment details'),
      _kv('Delivered on', _fmt(o.deliveredAt)),
      _kv('Installed on', _fmt(o.installedAt)),
      _kv('Completed on', _fmt(o.completedAt)),
    ])),
  ]);

  Widget _completedSide(OrderDetailModel o) => Column(children: [
    _summaryCard(o),
    const SizedBox(height: 18),
    DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DCardHead('Delivery address'),
      _kv('Recipient', o.customerName ?? '—'),
      _kv('Address', _addressStr(o)),
      const SizedBox(height: 6),
      const DCardHead('Payment'),
      if (o.paymentCard != null)
        Row(children: [
          Container(width: 44, height: 30, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.ink900, borderRadius: BorderRadius.circular(6)),
            child: const Text('CARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9))),
          const SizedBox(width: 10),
          Text('•••• ${o.paymentCard!.lastFour ?? '—'}  ·  Exp ${o.paymentCard!.expiryMonth}/${o.paymentCard!.expiryYear}',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink900)),
        ])
      else
        Text(_paymentLabel(o.paymentMethod), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink900)),
    ])),
  ]);

  // ── cancelled ──────────────────────────────────────────
  Widget _cancelledMain(OrderDetailModel o) => Column(children: [
    DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 46, height: 46,
          decoration: BoxDecoration(color: const Color(0xFFEEF2F9), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.cancel_outlined, color: AppColors.ink500, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Order cancelled', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink900)),
          const SizedBox(height: 3),
          Text('Cancelled ${_fmt(o.cancelledAt)}', style: const TextStyle(fontSize: 13, color: AppColors.ink500)),
        ])),
        StBadge(o.status),
      ]),
      if (o.cancellationReason != null) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.ink500),
            const SizedBox(width: 8),
            Expanded(child: Text('Reason: ${o.cancellationReason}', style: AppText.muted)),
          ]),
        ),
      ],
    ])),
    const SizedBox(height: 18),
    _itemsCard(o),
  ]);

  // ── shared cards ──────────────────────────────────────────
  Widget _itemsCard(OrderDetailModel o) {
    return DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DCardHead('Items'),
      if (o.items.isNotEmpty)
        ...o.items.map((it) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.all(Radius.circular(11))),
              child: const Icon(Icons.water_drop_outlined, size: 24, color: AppColors.blue200),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.productNameSnapshot, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink900)),
              const SizedBox(height: 2),
              Text('Qty ${it.quantity}', style: const TextStyle(fontSize: 12.5, color: AppColors.ink500)),
            ])),
            Text('${o.currency} ${it.lineTotal}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.ink900)),
          ]),
        ))
      else
        Text('${o.itemsCount ?? 1} item(s) ordered', style: AppText.muted),
    ]));
  }

  Widget _summaryCard(OrderDetailModel o) {
    final discount = double.tryParse(o.discountAmount) ?? 0;
    final tax = double.tryParse(o.taxAmount) ?? 0;
    return DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DCardHead('Order summary'),
      _sumRow('Subtotal', '${o.currency} ${o.subtotalAmount}'),
      if (discount > 0) _sumRow('Discount', '−${o.currency} ${o.discountAmount}', green: true),
      _sumRow('Delivery', 'Free', green: true),
      _sumRow('Installation', 'Free', green: true),
      if (tax > 0) _sumRow('VAT (${o.taxRate?.toInt() ?? 0}%)', '${o.currency} ${o.taxAmount}'),
      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: AppColors.line)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink900)),
        Text('${o.currency} ${o.totalAmount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink900)),
      ]),
    ]));
  }

  Widget _helpCard() {
    return DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DCardHead('Need help?'),
      Row(children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.chat_bubble_outline, color: AppColors.blue700, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Question about this order?', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink900)),
          SizedBox(height: 2),
          Text('Our team responds within hours.', style: TextStyle(fontSize: 12.5, color: AppColors.ink500)),
        ])),
      ]),
      const SizedBox(height: 14),
      DBtn('Contact Support', fullWidth: true, onTap: () => Navigator.of(context).pushNamed('/support')),
    ]));
  }

  // ── helpers ──────────────────────────────────────────
  List<TlStep> _trackingSteps(OrderDetailModel o) {
    final confirmed   = o.confirmedAt != null;
    final scheduled   = o.scheduledForAt != null;
    final delivered   = o.deliveredAt != null;
    final installed   = o.installedAt != null;
    return [
      TlStep('Order Placed',              _fmt(o.placedAt),           done: true),
      TlStep('Confirmed',                 confirmed  ? _fmt(o.confirmedAt)   : 'Awaiting confirmation',  done: confirmed,  pending: !confirmed),
      TlStep('Installation Scheduled',    scheduled  ? _fmt(o.scheduledForAt): 'To be scheduled',        done: scheduled,  pending: confirmed && !scheduled),
      TlStep('Delivered',                 delivered  ? _fmt(o.deliveredAt)   : 'Pending',                done: delivered,  pending: scheduled && !delivered),
      TlStep('Installed & Completed',     installed  ? _fmt(o.installedAt)   : 'Pending',                done: installed,  pending: delivered && !installed),
    ];
  }

  String _addressStr(OrderDetailModel o) {
    if (o.deliveryAddressLine1 != null) {
      return [o.deliveryAddressLine1, o.deliveryCity, o.deliveryPostcode]
          .where((s) => s != null && s!.isNotEmpty).join(', ');
    }
    if (o.deliveryAddress != null) {
      final a = o.deliveryAddress!;
      final country = a['country'];
      final countryName = country is Map ? country['name'] as String? : null;
      return [a['label'], a['city'], countryName]
          .where((s) => s != null && (s as String).isNotEmpty).join(', ');
    }
    return '—';
  }

  String _slotLabel(String? slot) {
    switch (slot) {
      case 'morning':   return 'Morning · 8AM–12PM';
      case 'afternoon': return 'Afternoon · 12PM–4PM';
      case 'evening':   return 'Evening · 4PM–7PM';
      default:          return '—';
    }
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'card':       return 'Credit / Debit Card';
      case 'apple_pay':  return 'Apple Pay';
      case 'google_pay': return 'Google Pay';
      default:           return method;
    }
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(k, style: const TextStyle(fontSize: 13, color: AppColors.ink500))),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink900))),
    ]),
  );

  Widget _sumRow(String k, String v, {bool green = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13.5, color: AppColors.ink600)),
      Text(v, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: green ? AppColors.green600 : AppColors.ink900)),
    ]),
  );
}
