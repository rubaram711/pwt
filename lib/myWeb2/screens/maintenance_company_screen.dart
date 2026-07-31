import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_shell.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Maintenance/maintenance_request_model.dart';
import '../../Models/Maintenance/maintenance_detail_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Backend/Machines/get_machines.dart';
import '../../Backend/Maintenance/get_maintenance_requests.dart';
import '../../Backend/Maintenance/create_maintenance_request.dart';
import '../../Backend/Maintenance/get_maintenance_request_details.dart';
import '../../Backend/Maintenance/cancel_maintenance_request.dart';
import '../../Backend/Maintenance/reschedule_maintenance_request.dart';
import '../state/app_state.dart';

const _slotLabels = {
  'morning':   'Morning (8AM – 12PM)',
  'afternoon': 'Afternoon (12PM – 4PM)',
  'evening':   'Evening (4PM – 7PM)',
};

String _fmtDate(String iso, {bool weekday = false}) {
  if (iso.isEmpty) return 'To be confirmed';
  try {
    final d = DateTime.parse(iso);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final base = '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    return weekday ? '${days[d.weekday - 1]}, $base' : base;
  } catch (_) {
    return iso;
  }
}

// ════════════════════════════════════════════════════════════════
// Maintenance list
// ════════════════════════════════════════════════════════════════
class CompanyMaintenanceScreen extends StatefulWidget {
  const CompanyMaintenanceScreen({super.key});
  @override
  State<CompanyMaintenanceScreen> createState() => _CompanyMaintenanceScreenState();
}

class _CompanyMaintenanceScreenState extends State<CompanyMaintenanceScreen> {
  bool _loading = false;
  String? _error;
  List<MaintenanceRequestModel> _requests = [];
  PaginationModel? _pagination;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() { _loading = true; _error = null; });
    final res = await getMaintenanceRequests(page: page);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _loading = false;
        _requests = res.data!.items;
        _pagination = res.data!.pagination;
        _page = page;
      });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load maintenance requests.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      active: 'maintenance',
      isCompany: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: 'Maintenance',
          subtitle: 'Schedule and track service visits for your fleet',
          action: _requests.isEmpty
              ? null
              : PwtButton('Schedule Maintenance', icon: Icons.add, onPressed: () => Navigator.of(context).pushNamed('/scheduleMaintenance')),
        ),
        if (_loading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_error != null)
          DashCard(child: Text(_error!, style: AppText.muted.copyWith(color: AppColors.danger)))
        else if (_requests.isEmpty)
          DashCard(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Column(children: [
              Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.soft, shape: BoxShape.circle), child: const Icon(Icons.build_outlined, size: 32, color: AppColors.ink400)),
              const SizedBox(height: 16),
              Text('No maintenance scheduled', style: AppText.h2.copyWith(fontSize: 19)),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text("Keep your fleet running smoothly. Book a service visit for one or more of your machines and we'll handle the rest.", style: AppText.body.copyWith(color: AppColors.ink500), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 18),
              PwtButton('Schedule Maintenance', icon: Icons.add, onPressed: () => Navigator.of(context).pushNamed('/scheduleMaintenance')),
            ])),
          ))
        else ...[
          Text('Maintenance Requests', style: AppText.h3),
          const SizedBox(height: 12),
          ..._requests.map((r) => _visitCard(context, r)),
        ],
        if (!_loading && (_pagination?.lastPage ?? 1) > 1) ...[
          const SizedBox(height: 14),
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

  Widget _visitCard(BuildContext context, MaintenanceRequestModel r) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/maintenanceDetails', arguments: r.id),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.build_outlined, color: AppColors.blue700)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Service visit — 1 machine', style: AppText.h3.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(r.preferredTime != null ? '${_fmtDate(r.preferredDate)} · ${_slotLabels[r.preferredTime] ?? r.preferredTime}' : _fmtDate(r.preferredDate), style: AppText.muted),
            ])),
            StatusBadge.forStatus(r.status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.ink400),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: AppColors.line)),
              child: Text(r.machine.displayName ?? r.machine.serialNumber, style: AppText.muted.copyWith(fontWeight: FontWeight.w600)),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Schedule maintenance
// ════════════════════════════════════════════════════════════════
class ScheduleMaintenanceScreen extends StatefulWidget {
  const ScheduleMaintenanceScreen({super.key});
  @override
  State<ScheduleMaintenanceScreen> createState() => _ScheduleMaintenanceScreenState();
}

class _ScheduleMaintenanceScreenState extends State<ScheduleMaintenanceScreen> {
  bool _loading = false;
  String? _error;
  bool _submitting = false;
  String? _submitError;
  List<MachineModel> _machines = [];
  MachineModel? _selectedMachine;
  bool _preselected = false;
  bool _argInit = false;
  bool _submitted = false;
  String _search = '';
  String _sort = 'installed_at';
  DateTime? _date;
  int _slot = 0;
  final _slots = const ['Morning (8AM – 12PM)', 'Afternoon (12PM – 4PM)', 'Evening (4PM – 7PM)'];
  static const _slotTimes = ['morning', 'afternoon', 'evening'];
  String _issueType = 'filter_change';
  static const _issueTypes = ['filter_change', 'leak', 'noise', 'low_pressure', 'water_quality', 'error_code', 'installation_fix', 'other'];
  static const _issueLabels = {'filter_change': 'Filter Change', 'leak': 'Leak', 'noise': 'Noise', 'low_pressure': 'Low Pressure', 'water_quality': 'Water Quality', 'error_code': 'Error Code', 'installation_fix': 'Installation Fix', 'other': 'Other'};
  final _notes = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argInit) return;
    _argInit = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is MachineModel) {
      setState(() { _selectedMachine = arg; _preselected = true; });
    } else {
      _loadMachines();
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadMachines() async {
    setState(() { _loading = true; _error = null; });
    final res = await getMachines(
      search: _search.isEmpty ? null : _search,
      sort: _sort,
    );
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _loading = false; _machines = res.data!.items; });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load machines.'; });
    }
  }

  void _onSearchChanged(String v) {
    setState(() => _search = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadMachines);
  }

  void _onSortChanged(String v) {
    setState(() => _sort = v);
    _loadMachines();
  }

  Future<void> _schedule() async {
    if (_selectedMachine == null || _date == null) return;
    setState(() { _submitting = true; _submitError = null; });
    final res = await submitMaintenanceRequest(
      machineId: _selectedMachine!.id,
      issueType: _issueType,
      description: _notes.text.trim(),
      preferredDate: _date!.toIso8601String().split('T').first,
      preferredTime: _slotTimes[_slot],
    );
    if (!mounted) return;
    if (res.success) {
      if (AppState.instance.isCompany) {
        Navigator.of(context).pushReplacementNamed('/companyMaintenance');
      } else {
        setState(() => _submitted = true);
      }
    } else {
      setState(() { _submitting = false; _submitError = res.message ?? 'Failed to submit request. Please try again.'; });
    }
  }

  Widget _serviceForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!_preselected) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm)),
          child: Text(_selectedMachine == null ? 'No machine selected' : (_selectedMachine!.displayName ?? _selectedMachine!.product.name), style: AppText.label),
        ),
        const SizedBox(height: 14),
      ],
      Text('Preferred date', style: AppText.label),
      const SizedBox(height: 7),
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 3)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 180)),
          );
          if (d != null) setState(() => _date = d);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.ink400),
            const SizedBox(width: 10),
            Text(_date == null ? 'Select a date' : _fmtDate(_date!.toIso8601String()), style: AppText.body),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      Text('Time slot', style: AppText.label),
      const SizedBox(height: 7),
      DropdownButtonFormField<int>(
        value: _slot,
        isExpanded: true,
        items: List.generate(_slots.length, (i) => DropdownMenuItem(value: i, child: Text(_slots[i], style: AppText.body))),
        onChanged: (v) => setState(() => _slot = v!),
      ),
      const SizedBox(height: 14),
      Text('Issue type', style: AppText.label),
      const SizedBox(height: 7),
      DropdownButtonFormField<String>(
        value: _issueType,
        isExpanded: true,
        items: _issueTypes.map((t) => DropdownMenuItem(value: t, child: Text(_issueLabels[t]!, style: AppText.body))).toList(),
        onChanged: (v) { if (v != null) setState(() => _issueType = v); },
      ),
      const SizedBox(height: 14),
      Text('Notes', style: AppText.label),
      const SizedBox(height: 7),
      TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(hintText: 'Access instructions, on-site contact, etc.')),
      if (_submitError != null) ...[
        const SizedBox(height: 10),
        Text(_submitError!, style: AppText.muted.copyWith(color: AppColors.danger)),
      ],
      const SizedBox(height: 16),
      PwtButton(
        _submitting ? 'Submitting…' : 'Schedule visit',
        fullWidth: true,
        onPressed: _selectedMachine == null || _date == null || _submitting ? null : _schedule,
      ),
      if (_selectedMachine == null)
        Padding(padding: const EdgeInsets.only(top: 10), child: Text('Select a machine to continue.', style: AppText.muted)),
      if (_selectedMachine != null && _date == null)
        Padding(padding: const EdgeInsets.only(top: 10), child: Text('Please select a preferred date.', style: AppText.muted)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      final isCompany = AppState.instance.isCompany;
      return DashboardShell(
        active: 'maintenance',
        isCompany: isCompany,
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.badgeGreenBg, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 42, color: AppColors.green600),
            ),
            const SizedBox(height: 20),
            Text('Request Submitted!', style: AppText.h2.copyWith(fontSize: 24), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              "We've received your maintenance request and will be in touch to confirm the visit.",
              style: AppText.body.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
              // PwtButton('View My Requests', onPressed: () => Navigator.of(context).pushReplacementNamed('/maintenance')),
              PwtButton('Back to Machines', variant: PwtBtn.outline, onPressed: () => Navigator.of(context).pushReplacementNamed(isCompany ? '/companyDashboard' : '/dashboard')),
            ]),
          ]),
        )),
      );
    }

    final wide = MediaQuery.of(context).size.width > 880;
    final machine = _selectedMachine;
    final machineUrl = machine?.product.imageUrl;
    const imgFallback = Icon(Icons.water_drop_outlined, size: 20, color: AppColors.blue200);
    final isCompany = AppState.instance.isCompany;
    return DashboardShell(
      active: 'maintenance',
      isCompany: isCompany,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: 'Schedule Maintenance',
          subtitle: _preselected
              ? (machine != null ? (machine.displayName ?? machine.product.name) : 'Service visit')
              : 'Select the machines that need a service visit',
          crumbs: const ['Maintenance', 'Schedule'],
          action: PwtButton('Back', variant: PwtBtn.outline, icon: Icons.arrow_back, onPressed: () => Navigator.of(context).pushReplacementNamed(isCompany ? '/companyMaintenance' : '/maintenance')),
        ),
        if (_preselected && machine != null) ...[
          DashCard(
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(6),
                child: machineUrl != null && machineUrl.isNotEmpty
                    ? Image.network(machineUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => imgFallback)
                    : imgFallback,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (machine.displayName != null && machine.displayName!.isNotEmpty)
                  Text(machine.displayName!, style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
                Text(machine.product.name, style: machine.displayName != null ? AppText.muted : AppText.label),
                if (machine.product.shortDescription != null)
                  Text(machine.product.shortDescription!, style: AppText.muted),
              ])),
            ]),
          ),
          const SizedBox(height: 18),
          DashCard(title: 'Service details', child: _serviceForm()),
        ] else
          Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: wide ? 3 : 0, child: DashCard(child: Column(children: [
              Row(children: [
                Expanded(child: TextField(
                  decoration: const InputDecoration(hintText: 'Search machines by name', prefixIcon: Icon(Icons.search, size: 18)),
                  onChanged: _onSearchChanged,
                )),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _sort,
                  underline: const SizedBox(),
                  items: const [
                    // DropdownMenuItem(value: 'device_type', child: Text('Device type')),
                    DropdownMenuItem(value: 'installed_at', child: Text('Date installed')),
                    DropdownMenuItem(value: 'name', child: Text('Name (A–Z)')),
                  ],
                  onChanged: (v) => _onSortChanged(v!),
                ),
              ]),
              const SizedBox(height: 14),
              if (_loading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
              else if (_error != null)
                Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_error!, style: AppText.muted.copyWith(color: AppColors.danger)))
              else ..._machines.map((m) {
                final on = _selectedMachine?.id == m.id;
                final url = m.product.imageUrl;
                const fallback = Icon(Icons.water_drop_outlined, size: 20, color: AppColors.blue200);
                return GestureDetector(
                  onTap: () => setState(() => _selectedMachine = m),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: on ? AppColors.blue50 : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: on ? AppColors.blue600 : AppColors.line, width: on ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? AppColors.blue700 : AppColors.ink300, width: 2)),
                        child: on ? const Center(child: SizedBox(width: 9, height: 9, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.blue700, shape: BoxShape.circle)))) : null,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(5),
                        child: url != null && url.isNotEmpty
                            ? Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => fallback)
                            : fallback,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (m.displayName != null && m.displayName!.isNotEmpty)
                          Text(m.displayName!, style: AppText.label.copyWith(fontWeight: FontWeight.w700)),
                        Text(m.product.name, style: m.displayName != null ? AppText.muted : AppText.label),
                        Text(m.product.shortDescription ?? m.product.code, style: AppText.muted),
                      ])),
                      Text('Installed ${_fmtDate(m.installedAt ?? '')}', style: AppText.muted),
                    ]),
                  ),
                );
              }),
              if (!_loading && _machines.isEmpty && _error == null)
                Padding(padding: const EdgeInsets.all(12), child: Text('No machines match your search.', style: AppText.muted)),
            ]))),
            SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 16),
            Expanded(flex: wide ? 2 : 0, child: DashCard(title: 'Service details', child: _serviceForm())),
          ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Maintenance detail
// ════════════════════════════════════════════════════════════════
class MaintenanceDetailsScreen extends StatefulWidget {
  const MaintenanceDetailsScreen({super.key});
  @override
  State<MaintenanceDetailsScreen> createState() => _MaintenanceDetailsScreenState();
}

class _MaintenanceDetailsScreenState extends State<MaintenanceDetailsScreen> {
  bool _loading = true;
  String? _error;
  MaintenanceDetailModel? _request;
  bool _idInit = false;
  int? _id;
  bool _cancelling = false;
  bool _rescheduling = false;
  final _slots = const ['Morning (8AM – 12PM)', 'Afternoon (12PM – 4PM)', 'Evening (4PM – 7PM)'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_idInit) {
      _idInit = true;
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id != null) {
        _id = id;
        _fetch(id);
      } else {
        setState(() { _loading = false; _error = 'Request not found.'; });
      }
    }
  }

  Future<void> _fetch(int id) async {
    final res = await getMaintenanceDetail(id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _loading = false; _request = res.data; });
    } else {
      setState(() { _loading = false; _error = res.message ?? 'Failed to load details.'; });
    }
  }

  Future<void> _cancel() async {
    final r = _request;
    if (r == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel maintenance request?'),
        content: const Text('Are you sure you want to cancel this maintenance request? Our team will be notified.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep visit')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel request', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    final res = await cancelMaintenance(id: r.id, reason: 'Customer requested cancellation');
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _cancelling = false; _request = res.data; });
    } else {
      setState(() => _cancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? 'Failed to cancel request.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _request;
    final label = r != null ? 'Service visit #${r.displayName}' : 'Service Visit';
    return DashboardShell(
      active: 'maintenance',
      isCompany: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DashHeader(
          title: label,
          subtitle: 'Scheduled maintenance details',
          crumbs: const ['Maintenance', 'Service visit'],
          action: PwtButton('Back', variant: PwtBtn.outline, icon: Icons.arrow_back, onPressed: () => Navigator.of(context).pushReplacementNamed('/companyMaintenance')),
        ),
        if (_loading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_error != null || r == null)
          DashCard(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Column(children: [
              const Icon(Icons.error_outline, size: 36, color: AppColors.ink400),
              const SizedBox(height: 12),
              Text('Visit not found', style: AppText.h3),
              const SizedBox(height: 6),
              Text(_error ?? 'This maintenance request no longer exists.', style: AppText.muted),
              const SizedBox(height: 16),
              PwtButton('Back to Maintenance', onPressed: () => Navigator.of(context).pushReplacementNamed('/companyMaintenance')),
            ])),
          ))
        else
          _body(r),
      ]),
    );
  }

  Widget _body(MaintenanceDetailModel r) {
    final wide = MediaQuery.of(context).size.width > 880;
    final cancelled = r.status == 'cancelled';
    final main = _mainCard(r);
    final side = _sideCards(r, cancelled);
    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: main),
        const SizedBox(width: 18),
        Expanded(child: side),
      ]);
    }
    return Column(children: [main, const SizedBox(height: 16), side]);
  }

  Widget _mainCard(MaintenanceDetailModel r) => Column(children: [
    DashCard(title: 'Visit details', action: StatusBadge.forStatus(r.status), child: Column(children: [
      _detail('Status', r.status),
      _detail('Issue type', r.issueType.replaceAll('_', ' ')),
      _detail('Priority', r.priority),
      _detail('Preferred date', _fmtDate(r.preferredDate, weekday: true)),
      if (r.preferredTime != null) _detail('Preferred time', _slotLabels[r.preferredTime] ?? r.preferredTime!),
      _detail('Machine', r.machine.displayName ?? r.machine.serialNumber),
      if (r.description.isNotEmpty) _detail('Notes', r.description),
    ])),
    const SizedBox(height: 16),
    DashCard(title: 'Machines on this visit', child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.build_outlined, size: 18, color: AppColors.blue700)),
        const SizedBox(width: 12),
        Text(r.machine.displayName ?? r.machine.serialNumber, style: AppText.label),
      ]),
    )),
  ]);

  Widget _sideCards(MaintenanceDetailModel r, bool cancelled) => Column(children: [
    DashCard(title: 'Manage visit', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        cancelled
            ? 'This maintenance request has been cancelled.'
            : 'Need to change this visit? You can reschedule it or request a cancellation. Our team will confirm by email.',
        style: AppText.body.copyWith(color: AppColors.ink500, height: 1.55),
      ),
      const SizedBox(height: 16),
      if (!cancelled) ...[
        PwtButton('Reschedule', icon: Icons.calendar_today_outlined, fullWidth: true, onPressed: () => _reschedule(r)),
        const SizedBox(height: 10),
        PwtButton('Request cancellation', variant: PwtBtn.danger, fullWidth: true, onPressed: _cancelling ? null : _cancel),
      ],
    ])),
    const SizedBox(height: 16),
    DashCard(title: 'Service support', child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_outline, color: AppColors.blue700)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('James Whitfield · Account Manager', style: AppText.label),
        const SizedBox(height: 2),
        Text('0800 123 4570 · james.w@pwt.com', style: AppText.muted),
      ])),
    ])),
  ]);

  Widget _detail(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(k, style: AppText.muted)),
      Expanded(child: Text(v, style: AppText.label)),
    ]),
  );

  void _reschedule(MaintenanceDetailModel r) {
    DateTime? newDate = DateTime.tryParse(r.preferredDate);
    int slot = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 22, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Reschedule Visit', style: AppText.h2.copyWith(fontSize: 19))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 12),
          Text('New date', style: AppText.label),
          const SizedBox(height: 7),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(
                context: ctx,
                initialDate: newDate ?? DateTime.now().add(const Duration(days: 3)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 180)),
              );
              if (d != null) set(() => newDate = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Text(newDate == null ? 'Select a date' : _fmtDate(newDate!.toIso8601String()), style: AppText.body),
            ),
          ),
          const SizedBox(height: 14),
          Text('Time slot', style: AppText.label),
          const SizedBox(height: 7),
          DropdownButtonFormField<int>(
            value: slot,
            isExpanded: true,
            items: List.generate(_slots.length, (i) => DropdownMenuItem(value: i, child: Text(_slots[i], style: AppText.body))),
            onChanged: (val) => set(() => slot = val!),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: PwtButton('Cancel', variant: PwtBtn.outline, fullWidth: true, onPressed: _rescheduling ? null : () => Navigator.pop(ctx))),
            const SizedBox(width: 12),
            Expanded(child: PwtButton(
              _rescheduling ? 'Saving…' : 'Save changes',
              fullWidth: true,
              onPressed: (newDate == null || _rescheduling) ? null : () async {
                set(() => _rescheduling = true);
                final dateStr = '${newDate!.year}-${newDate!.month.toString().padLeft(2,'0')}-${newDate!.day.toString().padLeft(2,'0')}';
                final slotKeys = ['morning', 'afternoon', 'evening'];
                final res = await rescheduleMaintenance(
                  id: _id!,
                  preferredDate: dateStr,
                  timeSlot: slotKeys[slot],
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() => _rescheduling = false);
                if (res.success && res.data != null) {
                  setState(() => _request = res.data);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message ?? 'Failed to reschedule. Please try again.')),
                  );
                }
              },
            )),
          ]),
        ]),
      )),
    );
  }
}
