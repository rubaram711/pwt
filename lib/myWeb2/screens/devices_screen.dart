import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_states.dart';
import '../state/app_state.dart';
import 'dashboard_shell.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Machines/machine_detail_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Models/Products/products_model.dart';
import '../../Backend/Machines/get_machines.dart';
import '../../Backend/Machines/get_machine_details.dart';
import '../../Backend/Products/get_products.dart';

String _fmt(String? iso) {
  if (iso == null) return '—';
  try {
    final dt = DateTime.parse(iso);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  } catch (_) { return iso; }
}

String _shortSerial(String s) =>
    s.length > 22 ? '${s.substring(0, 10)}…${s.substring(s.length - 8)}' : s;

// ════════════════════════════════════════════════════════════════
// Devices list
// ════════════════════════════════════════════════════════════════
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});
  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _loading = false;
  String? _error;
  List<MachineModel> _machines = [];
  PaginationModel? _pagination;
  int _page = 1;
  final _pageCache = <String, List<MachineModel>>{};
  List<ProductModel> _teaserProducts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    final cacheKey = ':$page';
    if (_pageCache.containsKey(cacheKey)) {
      setState(() { _machines = _pageCache[cacheKey]!; _page = page; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    final res = await getMachines(page: page);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _pageCache[cacheKey] = res.data!.items;
      setState(() {
        _loading = false;
        _machines = res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
      });
      if (res.data!.items.isEmpty) _loadTeasers();
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load machines.'; });
    }
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
    return DashboardShell(
      active: 'devices',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: 'My Machines',
          subtitle: 'Your water systems at a glance.',
          action: PwtButton('Shop new machine', icon: Icons.add, onPressed: () => Navigator.of(context).pushNamed('/shop')),
        ),
        if (_loading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_error != null)
          DashCard(child: Text(_error!, style: AppText.muted.copyWith(color: AppColors.danger)))
        else if (_machines.isEmpty)
          DashCard(child: SizedBox(width: double.infinity, child: Center(child: DevicesEmptyState(business: false, onBrowse: () => Navigator.of(context).pushNamed('/shop'), teaserProducts: _teaserProducts))))
        else
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 720 ? 2 : 1;
            final cardWidth = (c.maxWidth - (cols - 1) * 18) / cols;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: _machines.map((m) => SizedBox(width: cardWidth, child: _DeviceCard(m))).toList(),
            );
          }),
        if (!_loading && (_pagination?.lastPage ?? 1) > 1) ...[
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            PwtButton('Previous', variant: PwtBtn.outline, onPressed: _page > 1 ? () => _load(page: _page - 1) : null),
            const SizedBox(width: 16),
            Text('Page $_page of ${_pagination?.lastPage ?? 1}', style: AppText.muted),
            const SizedBox(width: 16),
            PwtButton('Next', variant: PwtBtn.outline, onPressed: _page < (_pagination?.lastPage ?? 1) ? () => _load(page: _page + 1) : null),
          ]),
        ],
      ]),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final MachineModel m;
  const _DeviceCard(this.m);

  Widget get _productImage {
    final url = m.product.imageUrl;
    final decoration = BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(12));
    const fallback = Icon(Icons.water_drop_outlined, size: 32, color: AppColors.blue200);
    return Container(
      width: 56, height: 56, decoration: decoration, padding: const EdgeInsets.all(8),
      child: url != null && url.isNotEmpty
          ? Image.network(url, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => fallback)
          : fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRent  = m.term == 'rent';
    final badge   = isRent ? StatusBadge.blue('Rented') : StatusBadge.green('Purchased');

    return DashCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _productImage,
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.product.name, style: AppText.h3),
            const SizedBox(height: 2),
            Text(m.product.shortDescription ?? m.product.code, style: AppText.muted),
          ])),
          badge,
        ]),
        if (m.needsMaintenance)
          _banner(Icons.calendar_today_outlined,
              m.nextMaintenanceDueAt != null
                  ? 'Maintenance due · ${_fmt(m.nextMaintenanceDueAt)}'
                  : 'Maintenance required',
              AppColors.blue700, AppColors.badgeBlueBg)
        else if (isRent) ...[
          // _row('Rental plan', 'Rental'),
          if (m.productPrice != null)
            _row('Rent', '${m.productPrice!.currency} ${m.productPrice!.amount}/mo'),
          _row('Next service', _fmt(m.nextMaintenanceDueAt), accent: true),
        ] else ...[
          _row('Installed', _fmt(m.installedAt)),
          _row('Next service', _fmt(m.nextMaintenanceDueAt)),
        ],
        const SizedBox(height: 14),
        PwtButton(
          'Request maintenance',
          variant: PwtBtn.outline,
          fullWidth: true,
          onPressed: () => Navigator.of(context).pushNamed('/scheduleMaintenance', arguments: m),
        ),
      ]),
    );
  }

  Widget _row(String k, String v, {bool accent = false}) => Padding(
    padding: const EdgeInsets.only(top: 9),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: AppText.muted),
      Text(v, style: AppText.label.copyWith(fontWeight: FontWeight.w700, color: accent ? AppColors.blue700 : AppColors.ink900)),
    ]),
  );

  Widget _banner(IconData ic, String t, Color fg, Color bg) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(ic, size: 16, color: fg),
      const SizedBox(width: 8),
      Expanded(child: Text(t, style: AppText.muted.copyWith(color: fg, fontWeight: FontWeight.w600))),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════
// Device detail
// ════════════════════════════════════════════════════════════════
class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key});
  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _loading = true;
  String? _error;
  MachineDetailModel? _machine;
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
        setState(() { _loading = false; _error = 'Machine not found.'; });
      }
    }
  }

  Future<void> _fetch(int id) async {
    final res = await getMachineDetail(id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _loading = false; _machine = res.data; });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load machine.'; });
    }
  }

  String get _backRoute => AppState.instance.isCompany ? '/companyDashboard' : '/dashboard';
  String get _maintenanceRoute => AppState.instance.isCompany ? '/companyMaintenance' : '/maintenance';

  @override
  Widget build(BuildContext context) {
    final m = _machine;
    final label = m != null ? m.product.name : 'Machine';
    return DashboardShell(
      active: 'devices',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: label,
          subtitle: m != null ? 'Serial: ${_shortSerial(m.serialNumber)}' : '',
          crumbs: ['Dashboard', 'Machines', label],
          action: PwtButton('Back to Machines', variant: PwtBtn.outline, icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pushReplacementNamed(_backRoute)),
        ),
        if (_loading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_error != null || m == null)
          DashCard(child: Column(children: [
            const SizedBox(height: 10),
            Text(_error ?? 'Machine not found.', style: AppText.muted.copyWith(color: AppColors.danger)),
            const SizedBox(height: 16),
            PwtButton('Back', onPressed: () => Navigator.of(context).pushReplacementNamed(_backRoute)),
            const SizedBox(height: 10),
          ]))
        else
          _body(m),
      ]),
    );
  }

  Widget _body(MachineDetailModel m) {
    return LayoutBuilder(builder: (ctx, c) {
      final wide = c.maxWidth > 900;
      final main = _mainCard(m);
      final side = _sideCards(m);
      if (wide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 16, child: main),
          const SizedBox(width: 18),
          Expanded(flex: 10, child: side),
        ]);
      }
      return Column(children: [main, const SizedBox(height: 18), side]);
    });
  }

  Widget _mainCard(MachineDetailModel m) => Column(children: [
    DashCard(title: 'Machine Info', action: StatusBadge.forStatus(m.status), child: Column(children: [
      _kv('Product', m.product.name),
      if (m.product.shortDescription != null) _kv('Description', m.product.shortDescription!),
      _kv('Serial number', m.serialNumber),
      _kv('Term', m.term == 'buy' ? 'Purchased' : 'Rented'),
      _kv('Installed', _fmt(m.installedAt)),
      _kv('Next service', m.nextMaintenanceDueAt != null ? _fmt(m.nextMaintenanceDueAt) : 'Not scheduled'),
      if (m.filterChangeIntervalMonths != null) _kv('Filter interval', '${m.filterChangeIntervalMonths} months'),
      if (m.notes != null && m.notes!.isNotEmpty) _kv('Notes', m.notes!),
    ])),
    if (m.maintenanceLogs.isNotEmpty) ...[
      const SizedBox(height: 18),
      DashCard(title: 'Maintenance History', action: Text('${m.totalLogsCount} total', style: AppText.muted), child: Column(children: [
        ...m.maintenanceLogs.map((log) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.build_outlined, size: 17, color: AppColors.blue700)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_fmt(log.completedAt ?? log.scheduledAt), style: AppText.label),
              if (log.notes != null && log.notes!.isNotEmpty) Text(log.notes!, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            StatusBadge.forStatus(log.status),
          ]),
        )),
      ])),
    ],
  ]);

  Widget _sideCards(MachineDetailModel m) => Column(children: [
    DashCard(title: 'Location', child: Column(children: [
      _kv('Address', m.address?.displayLine ?? '—'),
      if (m.address?.city != null) _kv('City', m.address!.city!),
      if (m.address?.countryName != null) _kv('Country', m.address!.countryName!),
      if (m.address?.recipientName != null) _kv('Recipient', m.address!.recipientName!),
    ])),
    const SizedBox(height: 18),
    DashCard(title: 'Service', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _kv('Open requests', '${m.openRequestsCount}'),
      _kv('Completed logs', '${m.totalLogsCount}'),
      if (m.needsMaintenance) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: const Color(0xFFFFF3DF), border: Border.all(color: const Color(0xFFFFD580)), borderRadius: BorderRadius.circular(10)),
          child: Row(children: const [
            Icon(Icons.warning_amber_outlined, size: 14, color: Color(0xFFB45309)),
            SizedBox(width: 8),
            Expanded(child: Text('Maintenance required', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309)))),
          ]),
        ),
      ],
      if (m.canRequestMaintenance) ...[
        const SizedBox(height: 14),
        PwtButton('Request Maintenance', fullWidth: true, onPressed: () => Navigator.of(context).pushNamed(_maintenanceRoute)),
      ],
    ])),
  ]);

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(k, style: AppText.muted)),
      Expanded(child: Text(v, style: AppText.label)),
    ]),
  );
}



