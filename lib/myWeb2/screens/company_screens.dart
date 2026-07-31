import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dashboard_widgets.dart';
import 'dashboard_shell.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Backend/Machines/get_machines.dart';

String _fmt(String? iso) {
  if (iso == null) return '—';
  try {
    final dt = DateTime.parse(iso);
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) { return iso; }
}

class CompanyDevicesScreen extends StatefulWidget {
  const CompanyDevicesScreen({super.key});
  @override
  State<CompanyDevicesScreen> createState() => _CompanyDevicesScreenState();
}

class _CompanyDevicesScreenState extends State<CompanyDevicesScreen> {
  int _tab = 0;
  final _tabs = const ['All', 'Rented', 'Purchased'];
  static const _tabStatuses = <String?>[null, 'rented', 'purchased'];

  bool _loading = false;
  String? _error;
  List<MachineModel> _machines = [];
  PaginationModel? _pagination;
  Map<String, dynamic>? _stats;
  int _page = 1;
  String? _currentStatus;
  final _pageCache = <String, List<MachineModel>>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1, String? status}) async {
    final cacheKey = '${status ?? ''}:$page';
    if (_pageCache.containsKey(cacheKey)) {
      setState(() { _machines = _pageCache[cacheKey]!; _page = page; _currentStatus = status; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    final res = await getMachines(page: page, status: status);
    if (!mounted) return;
    if (res.success && res.data != null) {
      _pageCache[cacheKey] = res.data!.items;
      setState(() {
        _loading = false;
        _machines = res.data!.items;
        _pagination = res.data!.pagination;
        _stats = res.data!.meta?['stats'] as Map<String, dynamic>?;
        _page = page;
        _currentStatus = status;
      });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load machines.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total     = _stats?['total']?.toString() ?? '${_machines.length}';
    final rented    = _stats?['rented']?.toString() ?? '—';
    final purchased = _stats?['purchased']?.toString() ?? '—';

    return DashboardShell(
      active: 'devices',
      isCompany: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: 'Machines',
          subtitle: 'All water systems across your business account.',
          action: PwtButton('Request Quotation', icon: Icons.add, onPressed: () => Navigator.of(context).pushNamed('/rfq')),
        ),
        KpiGrid(tiles: [
          KpiTile(label: 'Total Machines', value: total, sub: 'Across all sites', icon: Icons.inventory_2_outlined, iconColor: AppColors.blue700),
          KpiTile(label: 'Rented', value: rented, sub: 'Monthly billing', icon: Icons.autorenew, iconColor: AppColors.amber),
          KpiTile(label: 'Purchased', value: purchased, sub: 'Owned outright', icon: Icons.check_circle_outline, iconColor: AppColors.green600),
        ]),
        const SizedBox(height: 18),
        DashCard(
          title: 'All Machines',
          action: _tabBar(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_loading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            else if (_error != null)
              Text(_error!, style: AppText.muted.copyWith(color: AppColors.danger))
            else if (_machines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Column(children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.soft, shape: BoxShape.circle), child: const Icon(Icons.water_drop_outlined, size: 26, color: AppColors.ink400)),
                  const SizedBox(height: 12),
                  Text('No machines in this category', style: AppText.label),
                  const SizedBox(height: 4),
                  Text('Try selecting a different filter above.', style: AppText.muted),
                ])),
              )
            else
              Column(children: _machines.map((m) => _deviceRow(context, m)).toList()),
          ]),
        ),
        if (!_loading && (_pagination?.lastPage ?? 1) > 1) ...[
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            PwtButton('Previous', variant: PwtBtn.outline, onPressed: _page > 1 ? () => _load(page: _page - 1, status: _currentStatus) : null),
            const SizedBox(width: 16),
            Text('Page $_page of ${_pagination?.lastPage ?? 1}', style: AppText.muted),
            const SizedBox(width: 16),
            PwtButton('Next', variant: PwtBtn.outline, onPressed: _page < (_pagination?.lastPage ?? 1) ? () => _load(page: _page + 1, status: _currentStatus) : null),
          ]),
        ],
      ]),
    );
  }

  Widget _tabBar() => Container(
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
  );

  Widget _productImage(MachineModel m) {
    final url = m.product.imageUrl;
    const fallback = Icon(Icons.water_drop_outlined, size: 26, color: AppColors.blue200);
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
      padding: const EdgeInsets.all(6),
      child: url != null && url.isNotEmpty
          ? Image.network(url, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => fallback)
          : fallback,
    );
  }

  Widget _deviceRow(BuildContext context, MachineModel m) {
    final wide = MediaQuery.of(context).size.width > 760;
    final isRent = m.term == 'rent';
    final planLine = '${isRent ? 'Rental' : 'Purchased'} · ${_fmt(m.installedAt)}';
    final infoLine = m.nextMaintenanceDueAt != null
        ? 'Next: ${_fmt(m.nextMaintenanceDueAt)}'
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: AppColors.line)),
      child: Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _productImage(m),
        const SizedBox(width: 12),
        Expanded(flex: wide ? 3 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.product.name, style: AppText.label),
          Text(m.product.shortDescription ?? m.product.code, style: AppText.muted),
          if (m.needsMaintenance) Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(children: [
              const Icon(Icons.build_outlined, size: 13, color: AppColors.blue700),
              const SizedBox(width: 5),
              Text(
                m.nextMaintenanceDueAt != null
                    ? 'Maintenance due · ${_fmt(m.nextMaintenanceDueAt)}'
                    : 'Maintenance required',
                style: AppText.muted.copyWith(color: AppColors.blue700),
              ),
            ]),
          ),
        ])),
        SizedBox(width: wide ? 12 : 0, height: wide ? 0 : 10),
        Expanded(flex: wide ? 3 : 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(planLine, style: AppText.body),
          Text(infoLine, style: AppText.muted),
        ])),
        SizedBox(width: wide ? 12 : 0, height: wide ? 0 : 10),
        SizedBox(width: wide ? 110 : null, child: isRent ? StatusBadge.blue('Rented') : StatusBadge.green('Purchased')),
        SizedBox(width: wide ? 50 : 0, height: wide ? 0 : 10),
        PwtButton('Request maintenance', variant: PwtBtn.outline, onPressed: () => Navigator.of(context).pushNamed('/scheduleMaintenance', arguments: m)),
      ]),
    );
  }
}

// NOTE: CompanyOrdersScreen lives in company_orders_screen.dart
