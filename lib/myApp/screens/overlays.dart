// Maintenance request flow + request detail. Ported from proto/overlays.jsx
// (MaintenanceFlowScreen, RequestDetailScreen).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/asset_resolver.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Backend/Maintenance/create_maintenance_request.dart';
import '../../Backend/Maintenance/get_maintenance_request_details.dart';
import '../../Backend/Maintenance/cancel_maintenance_request.dart';
import '../../Backend/Maintenance/reschedule_maintenance_request.dart';
import '../../Models/Maintenance/maintenance_detail_model.dart';
import '../widgets/layout.dart';
import '../widgets/primitives.dart';
import '../widgets/pwt_icons.dart';

class MaintenanceSheet extends StatefulWidget {
  const MaintenanceSheet({super.key, required this.machine});
  final MachineModel machine;

  @override
  State<MaintenanceSheet> createState() => _MaintenanceSheetState();
}

class _MaintenanceSheetState extends State<MaintenanceSheet> {
  bool _success = false;
  bool _submitting = false;
  String _issueType = 'filter_change';
  DateTime? _selectedDate;
  int _slot = 0;
  final _notes = TextEditingController();

  static const _slots = ['Morning (8AM – 12PM)', 'Afternoon (12PM – 4PM)', 'Evening (4PM – 7PM)'];
  static const _slotTimes = ['morning', 'afternoon', 'evening'];
  static const _monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _issueTypes = ['filter_change', 'leak', 'noise', 'low_pressure', 'water_quality', 'error_code', 'installation_fix', 'other'];
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

  @override
  void initState() {
    super.initState();
    _notes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  String _fmtDisplay(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  String _fmtApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_selectedDate == null) return;
    setState(() => _submitting = true);
    final m = widget.machine;
    final res = await submitMaintenanceRequest(
      machineId: m.id,
      issueType: _issueType,
      description: _notes.text.trim(),
      preferredDate: _fmtApi(_selectedDate!),
      preferredTime: _slotTimes[_slot],
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (res.success) {
      setState(() => _success = true);
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
    final d = widget.machine;

    return DetailScaffold(
      title: s['requestMaintenance'],
      onBack: () => Navigator.pop(context),
      body: _success
          ? ListView(
              children: [
                SuccessView(
                  title: ar ? 'تم استلام طلبك' : 'Request received',
                  body: ar ? 'سيصل الفني قريباً.' : 'A technician will be assigned shortly.',
                  accent: PwtColors.brand,
                  detail: PwtCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListRow(
                          leading: PwtIcons.cal,
                          title: _fmtDisplay(_selectedDate!),
                          sub: _slots[_slot],
                        ),
                        ListRow(
                          leading: PwtIcons.message,
                          title: ar
                              ? 'سنرسل تأكيداً عبر الواتساب'
                              : "You'll get a WhatsApp confirmation",
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: PwtButton(label: s['done']!, full: true, onPressed: () => Navigator.pop(context)),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // device card
                PwtCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 56,
                        decoration: BoxDecoration(
                          color: PwtColors.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: PwtColors.hairline),
                        ),
                        alignment: Alignment.center,
                        child: hasLocalAsset('assets/products/${d.product.code}.png')
                            ? Image(image: pwtImage('assets/products/${d.product.code}.png'), height: 42, fit: BoxFit.contain)
                            : (d.product.imageUrl != null && d.product.imageUrl!.isNotEmpty
                                ? Image.network(d.product.imageUrl!, height: 42, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.water_drop_outlined, size: 24, color: PwtColors.brand))
                                : const Icon(Icons.water_drop_outlined, size: 24, color: PwtColors.brand)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.product.name, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                d.publicId.isNotEmpty ? d.publicId : d.serialNumber,
                                style: PwtType.mono(size: 11.5, color: PwtColors.textTer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // issue type dropdown
                _sectionTitle(ar ? 'نوع المشكلة' : 'Issue type'),
                DropdownButtonFormField<String>(
                  value: _issueType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PwtRadius.md),
                      borderSide: const BorderSide(color: PwtColors.hairline2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PwtRadius.md),
                      borderSide: const BorderSide(color: PwtColors.brand, width: 1.5),
                    ),
                  ),
                  items: _issueTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(_issueLabels[t]!, style: PwtType.body())))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _issueType = v);
                  },
                ),
                // date picker
                _sectionTitle(ar ? 'التاريخ المفضَّل' : 'Preferred date'),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: PwtColors.surface,
                      border: Border.all(
                        color: _selectedDate != null ? PwtColors.brand : PwtColors.hairline2,
                        width: 1.5,
                      ),
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
                // time slot
                _sectionTitle(ar ? 'الوقت المناسب' : 'Time slot'),
                for (int i = 0; i < _slots.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _slotChip(i),
                  ),
                // notes
                _sectionTitle(ar ? 'ملاحظات' : 'Notes'),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: ar
                        ? 'تعليمات الوصول أو معلومات التواصل…'
                        : 'Access instructions, on-site contact…',
                    hintStyle: PwtType.body(color: PwtColors.textTer),
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PwtRadius.md),
                      borderSide: const BorderSide(color: PwtColors.hairline2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PwtRadius.md),
                      borderSide: const BorderSide(color: PwtColors.brand, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                PwtButton(
                  label: _submitting ? '...' : s['confirm']!,
                  full: true,
                  disabled: _submitting || _selectedDate == null || _notes.text.trim().isEmpty,
                  onPressed: (_submitting || _selectedDate == null || _notes.text.trim().isEmpty) ? null : _submit,
                ),
              ],
            ),
    );
  }

  Widget _slotChip(int i) {
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
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: on ? PwtColors.brand : PwtColors.hairline2, width: 2),
              ),
              child: on
                  ? const Center(
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(decoration: BoxDecoration(color: PwtColors.brand, shape: BoxShape.circle)),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                _slots[i],
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  color: on ? PwtColors.brandDeep : PwtColors.textPri,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Eyebrow(t),
      );
}

// ─── Request detail (business) ───
class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key, required this.request});
  final MaintenanceRequest request;

  Color _statusColor(String st) => switch (st) {
        'scheduled' => PwtColors.brand,
        'in_progress' => PwtColors.warning,
        'completed' => PwtColors.success,
        _ => PwtColors.textSec,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = Strings.of(app.lang);
    final r = request;
    return DetailScaffold(
      title: '#${r.id}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PwtCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(r.issue, style: PwtType.subtitle().copyWith(fontSize: 17, fontWeight: FontWeight.w700))),
                    Pill(label: r.statusLabel, color: _statusColor(r.status), dot: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text(r.device, style: PwtType.body(color: PwtColors.textSec)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PwtCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListRow(leading: PwtIcons.cal, title: r.schedule, sub: s['timeWindow']),
                ListRow(leading: PwtIcons.user, title: r.tech, sub: s['technician']),
                ListRow(leading: PwtIcons.cube, title: r.device, sub: r.deviceId),
                ListRow(leading: PwtIcons.info, title: r.raised, sub: app.isArabic ? 'تاريخ الطلب' : 'Raised on', last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Maintenance request detail (API-backed) ───
class MaintenanceApiDetailScreen extends StatefulWidget {
  const MaintenanceApiDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<MaintenanceApiDetailScreen> createState() => _MaintenanceApiDetailScreenState();
}

class _MaintenanceApiDetailScreenState extends State<MaintenanceApiDetailScreen> {
  bool _loading = true;
  String? _error;
  MaintenanceDetailModel? _detail;
  bool _cancelling = false;
  bool _rescheduling = false;

  static const _slotLabels = {
    'morning':   'Morning (8AM – 12PM)',
    'afternoon': 'Afternoon (12PM – 4PM)',
    'evening':   'Evening (4PM – 7PM)',
  };
  static const _slots     = ['Morning (8AM – 12PM)', 'Afternoon (12PM – 4PM)', 'Evening (4PM – 7PM)'];
  static const _slotTimes = ['morning', 'afternoon', 'evening'];

  static const _issueLabels = {
    'filter_change': 'Filter Change', 'leak': 'Leak', 'noise': 'Noise',
    'low_pressure': 'Low Pressure', 'water_quality': 'Water Quality',
    'error_code': 'Error Code', 'installation_fix': 'Installation Fix', 'other': 'Other',
  };

  static const _statusLabels = {
    'pending': 'Pending', 'scheduled': 'Scheduled',
    'in_progress': 'In Progress', 'completed': 'Completed', 'cancelled': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await getMaintenanceDetail(widget.id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success && res.data != null) {
        _detail = res.data;
      } else {
        _error = res.message ?? 'Failed to load request.';
      }
    });
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel maintenance request?'),
        content: const Text('Are you sure you want to cancel this request? Our team will be notified.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep visit')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: PwtColors.error),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    final res = await cancelMaintenance(id: widget.id, reason: 'Customer requested cancellation');
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _cancelling = false; _detail = res.data; });
    } else {
      setState(() => _cancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? 'Failed to cancel request.')));
    }
  }

  void _reschedule(MaintenanceDetailModel r) {
    DateTime? newDate = DateTime.tryParse(r.preferredDate);
    int slot = _slotTimes.indexOf(r.preferredTime ?? 'morning').clamp(0, 2);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PwtColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        bool submitting = false;
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Reschedule Visit', style: PwtType.title().copyWith(fontSize: 19))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 14),
            Text('New date', style: PwtType.label(weight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
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
                decoration: BoxDecoration(
                  border: Border.all(color: newDate != null ? PwtColors.brand : PwtColors.hairline2, width: 1.5),
                  borderRadius: BorderRadius.circular(PwtRadius.md),
                ),
                child: Row(children: [
                  Icon(PwtIcons.cal, size: 18, color: newDate != null ? PwtColors.brand : PwtColors.textTer),
                  const SizedBox(width: 10),
                  Text(
                    newDate == null
                        ? 'Select a date'
                        : '${newDate!.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][newDate!.month-1]} ${newDate!.year}',
                    style: PwtType.body(),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Text('Time slot', style: PwtType.label(weight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: slot,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(PwtRadius.md), borderSide: BorderSide(color: PwtColors.hairline2)),
              ),
              items: List.generate(_slots.length, (i) => DropdownMenuItem(value: i, child: Text(_slots[i]))),
              onChanged: (v) { if (v != null) set(() => slot = v); },
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: PwtButton(label: 'Cancel', variant: PwtButtonVariant.ghost, full: true, onPressed: submitting ? null : () => Navigator.pop(ctx))),
              const SizedBox(width: 12),
              Expanded(child: PwtButton(
                label: submitting ? '...' : 'Save changes',
                full: true,
                onPressed: (newDate == null || submitting) ? null : () async {
                  set(() => submitting = true);
                  final dateStr = '${newDate!.year}-${newDate!.month.toString().padLeft(2,'0')}-${newDate!.day.toString().padLeft(2,'0')}';
                  final res = await rescheduleMaintenance(
                    id: widget.id,
                    preferredDate: dateStr,
                    timeSlot: _slotTimes[slot],
                  );
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  if (res.success && res.data != null) {
                    setState(() { _detail = res.data; _rescheduling = false; });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message ?? 'Failed to reschedule. Please try again.')),
                    );
                  }
                },
              )),
            ]),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _detail;
    return DetailScaffold(
      title: r != null ? (r.displayName ?? r.publicId) : 'Request',
      body: _loading
          ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(strokeWidth: 2, color: PwtColors.brand)))
          : _error != null
              ? Center(child: Padding(padding: EdgeInsets.all(24), child: Text(_error!, style: PwtType.body(color: PwtColors.error))))
              : _body(r!),
    );
  }

  Widget _body(MaintenanceDetailModel r) {
    final cancelled = r.status == 'cancelled';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Pill(label: _statusLabels[r.status] ?? r.status, color: _statusColor(r.status), dot: true),
        const SizedBox(height: 14),
        PwtCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListRow(leading: PwtIcons.wrench, title: _issueLabels[r.issueType] ?? r.issueType.replaceAll('_', ' '), sub: 'Issue type'),
              ListRow(leading: Icons.flag_outlined, title: r.priority, sub: 'Priority'),
              ListRow(leading: PwtIcons.cal, title: r.preferredDate, sub: 'Preferred date'),
              if (r.preferredTime != null)
                ListRow(leading: Icons.schedule_outlined, title: _slotLabels[r.preferredTime] ?? r.preferredTime!, sub: 'Preferred time'),
              ListRow(
                leading: PwtIcons.drop,
                title: r.machine.displayName ?? r.machine.serialNumber,
                sub: r.machine.productName ?? r.machine.serialNumber,
                last: r.description.isEmpty,
              ),
              if (r.description.isNotEmpty)
                ListRow(leading: PwtIcons.info, title: r.description, sub: 'Notes', last: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PwtCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              cancelled
                  ? 'This maintenance request has been cancelled.'
                  : 'Need to change this visit? You can reschedule it or request a cancellation.',
              style: PwtType.body(color: PwtColors.textSec),
            ),
            if (!cancelled) ...[
              const SizedBox(height: 14),
              PwtButton(label: 'Reschedule', full: true, icon: PwtIcons.cal, onPressed: () => _reschedule(r)),
              const SizedBox(height: 10),
              PwtButton(
                label: _cancelling ? '...' : 'Request cancellation',
                full: true,
                variant: PwtButtonVariant.destructive,
                onPressed: _cancelling ? null : _cancel,
              ),
            ],
          ]),
        ),
      ],
    );
  }

  Color _statusColor(String st) => switch (st) {
    'pending'     => PwtColors.warning,
    'scheduled'   => PwtColors.brand,
    'in_progress' => PwtColors.brand,
    'completed'   => PwtColors.success,
    'cancelled'   => PwtColors.textSec,
    _             => PwtColors.textSec,
  };
}
