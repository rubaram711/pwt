import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dashboard_widgets.dart';
import 'dashboard_shell.dart';

// NOTE: the individual OrdersScreen now lives in individual_orders_screen.dart
// (faithful list + ongoing/completed order detail on the dash_kit shell).

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 880;
    return DashboardShell(
      active: 'maintenance',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const DashHeader(title: 'Maintenance Requests', subtitle: 'Submit and track your maintenance requests', crumbs: ['Dashboard', 'Maintenance Requests']),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(AppRadius.lg)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.water_drop, color: AppColors.blue700)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Filter replacement due in 14 days', style: AppText.h3.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text('PW50-R · scheduled for 14 June 2026. Free under your warranty & rental plans.', style: AppText.body.copyWith(color: AppColors.ink600)),
            ])),
            const SizedBox(width: 12),
            PwtButton('Confirm Visit', onPressed: () {}),
          ]),
        ),
        const SizedBox(height: 18),
        Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: wide ? 1 : 0, child: Column(children: [
            DashCard(title: 'Submit a Maintenance Request', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: _select('Product', const ['PW50-R · Hot & Cold', 'PW100-B · 3 Taps', 'PW-RO5 · Reverse Osmosis'])), const SizedBox(width: 12), Expanded(child: _select('Issue type', const ['Filter replacement', 'Not cooling / heating', 'Leak', 'General service']))]),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: _select('Preferred time', const ['Morning · 8–12', 'Afternoon · 12–4', 'Evening · 4–7'])), const SizedBox(width: 12), const Expanded(child: SizedBox())]),
              const SizedBox(height: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Describe the issue', style: AppText.label), const SizedBox(height: 7), const TextField(maxLines: 3, decoration: InputDecoration(hintText: "Tell us what's happening…"))]),
              const SizedBox(height: 16),
              PwtButton('Submit Request', icon: Icons.build_outlined, fullWidth: true, onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.ink900))),
            ])),
            const SizedBox(height: 16),
            DashCard(title: 'Service History', child: Column(children: [
              _historyRow('Filter replacement · PW50-R', '14 Mar 2026 · Tech: D. Roberts'),
              _historyRow('Annual service · PW100-B', '02 Feb 2026 · Tech: S. Khan'),
              _historyRow('Filter replacement · PW-RO5', '12 Dec 2025 · Tech: D. Roberts'),
            ])),
          ])),
          SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 16),
          Expanded(flex: wide ? 1 : 0, child: Column(children: [
            DashCard(title: 'Upcoming Technician Visit', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.badgeBlueBg, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.person_outline, color: AppColors.blue700)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('David Roberts', style: AppText.label), const SizedBox(height: 2), Text('PWT Certified Technician', style: AppText.muted)])),
              ]),
              const SizedBox(height: 16),
              const Timeline(steps: [
                TimelineStep('Request received', 'Filter replacement · PW50-R', done: true),
                TimelineStep('Technician assigned', 'David Roberts', done: true),
                TimelineStep('Scheduled visit', '14 June 2026 · Morning slot', active: true),
                TimelineStep('Service completed', 'Pending'),
              ]),
              PwtButton('Reschedule Visit', variant: PwtBtn.outline, fullWidth: true, onPressed: () {}),
            ])),
            const SizedBox(height: 16),
            DashCard(title: 'Filter Replacement Schedule', child: Column(children: [
              _progressRow('PW50-R', 'Next: 14 Jun 2026', .86, AppColors.amber),
              _progressRow('PW100-B', 'Next: 02 Aug 2026', .54, AppColors.blue700),
              _progressRow('PW-RO5', 'Next: 12 Sep 2026', .32, AppColors.green600),
            ])),
          ])),
        ]),
      ]),
    );
  }

  Widget _select(String label, List<String> opts) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(value: opts.first, isExpanded: true, items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppText.body, overflow: TextOverflow.ellipsis))).toList(), onChanged: (_) {}),
      ]);

  Widget _historyRow(String t, String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.build_outlined, size: 18, color: AppColors.blue700)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: AppText.label), const SizedBox(height: 2), Text(s, style: AppText.muted)])),
          StatusBadge.green('Completed'),
        ]),
      );

  Widget _progressRow(String name, String next, double pct, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppText.label), const SizedBox(height: 2), Text(next, style: AppText.muted)])),
          SizedBox(width: 120, child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: AppColors.line, color: color))),
        ]),
      );
}
