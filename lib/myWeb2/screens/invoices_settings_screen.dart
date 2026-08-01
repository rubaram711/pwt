import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/dashboard_widgets.dart';
import 'dashboard_shell.dart';
import '../../Backend/Users/update_user.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['INV-2026-0091', '24 May 2026', 'Order #PW12560 — PW50-R', '£880', 'Paid'],
      ['INV-2026-0088', '12 May 2026', 'Rental — May 2026', '£58', 'Paid'],
      ['INV-2026-0081', '10 May 2026', 'Order #PW12488 — PW-RO5', '£850', 'Paid'],
      ['INV-2026-0072', '02 May 2026', 'Order #PW12395 — PW30-C', '£590', 'Processing'],
      ['INV-2026-0066', '18 Apr 2026', 'Order #PW12210 — Filters Set', '£120', 'Paid'],
      ['INV-2026-0059', '12 Apr 2026', 'Rental — April 2026', '£58', 'Paid'],
    ];
    return DashboardShell(
      active: 'invoices',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const DashHeader(title: 'Invoices', subtitle: 'View and download your billing documents', crumbs: ['Dashboard', 'Invoices']),
        const KpiGrid(tiles: [
          KpiTile(label: 'Total Invoices', value: '9', sub: 'Since Mar 2026', icon: Icons.description_outlined, iconColor: AppColors.blue700),
          KpiTile(label: 'Total Paid', value: '£4,210', sub: 'All settled', icon: Icons.check_circle_outline, iconColor: AppColors.green600),
          KpiTile(label: 'Outstanding', value: '£0', sub: 'Nothing due', icon: Icons.schedule, iconColor: AppColors.amber),
        ]),
        const SizedBox(height: 18),
        DashCard(
          title: 'All Invoices',
          action: PwtButton('Download all (.zip)', variant: PwtBtn.outline, onPressed: () {}),
          child: DashTable(
            headers: const ['Invoice', 'Date', 'Description', 'Amount', 'Status', ''],
            rows: rows.map((r) => [
                  Text(r[0], style: AppText.label.copyWith(color: AppColors.blue700)),
                  Text(r[1], style: AppText.body),
                  Text(r[2], style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(r[3], style: AppText.label),
                  Align(alignment: Alignment.centerLeft, child: StatusBadge.forStatus(r[4])),
                  Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () {}, child: const Text('Download'))),
                ]).toList(),
          ),
        ),
      ]),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notif = {'maint': true, 'billing': true, 'orders': true, 'offers': false};
  bool _twoFa = false;

  final _curPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confPwCtrl = TextEditingController();
  bool _savingPassword = false;
  String? _passwordError;

  @override
  void dispose() {
    _curPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 880;
    return DashboardShell(
      active: 'settings',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const DashHeader(title: 'Settings', subtitle: 'Notifications, preferences and account security'),
        Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hidden for now — will return later.
          // Expanded(flex: wide ? 1 : 0, child: Column(children: [
          //   DashCard(title: 'Notifications', child: Column(children: [
          //     _switchRow('Maintenance reminders', 'Service due dates and scheduled visits', 'maint'),
          //     _switchRow('Billing & payments', 'Upcoming rental payments and receipts', 'billing'),
          //     _switchRow('Order updates', 'Delivery and installation status', 'orders'),
          //     _switchRow('Offers & news', 'Occasional product news and promotions', 'offers'),
          //   ])),
          //   const SizedBox(height: 16),
          //   DashCard(title: 'Preferences', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //     Row(children: [
          //       Expanded(child: _langSelect()),
          //       const SizedBox(width: 12),
          //       Expanded(child: _select('Currency', const ['GBP (£)', 'EUR (€)', 'USD (\$)'])),
          //     ]),
          //     const SizedBox(height: 16),
          //     PwtButton('Save Preferences', onPressed: () => _toast('Preferences saved')),
          //   ])),
          // ])),
          // SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 16),
          Expanded(flex: wide ? 1 : 0, child: DashCard(title: 'Security', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _passField('Current password', _curPwCtrl),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _passField('New password', _newPwCtrl)), const SizedBox(width: 12), Expanded(child: _passField('Confirm new password', _confPwCtrl))]),
            if (_passwordError != null) ...[
              const SizedBox(height: 8),
              Text(_passwordError!, style: AppText.muted.copyWith(color: AppColors.danger)),
            ],
            const SizedBox(height: 16),
            PwtButton(_savingPassword ? 'Updating…' : 'Update Password', onPressed: _savingPassword ? null : _changePassword),
            // Hidden for now — will return later.
            // const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider(height: 1, color: AppColors.line)),
            // Row(children: [
            //   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Two-factor authentication', style: AppText.label), const SizedBox(height: 2), Text('Add an extra layer of security at sign-in', style: AppText.muted)])),
            //   PwtToggle(value: _twoFa, onChanged: (v) => setState(() => _twoFa = v)),
            // ]),
          ]))),
        ]),
      ]),
    );
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.ink900));

  Widget _switchRow(String h, String p, String key) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h, style: AppText.label), const SizedBox(height: 2), Text(p, style: AppText.muted)])),
          PwtToggle(value: _notif[key]!, onChanged: (v) => setState(() => _notif[key] = v)),
        ]),
      );

  Widget _select(String label, List<String> opts) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          value: opts.first,
          isExpanded: true,
          items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppText.body))).toList(),
          onChanged: (_) {},
        ),
      ]);

  /// Language preference — backed by the same AppState.lang the header switcher
  /// uses, so the two controls always agree.
  Widget _langSelect() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Language', style: AppText.label),
        const SizedBox(height: 7),
        AnimatedBuilder(
          animation: AppState.instance,
          builder: (_, __) => DropdownButtonFormField<String>(
            value: AppState.instance.lang,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: 'en', child: Text('English', style: AppText.body)),
              DropdownMenuItem(value: 'ar', child: Text('العربية', style: AppText.body)),
            ],
            onChanged: (v) { if (v != null) AppState.instance.setLang(v); },
          ),
        ),
      ]);

  Widget _passField(String label, TextEditingController controller) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: true,
          autofillHints: null,
          enableSuggestions: false,
          autocorrect: false,
          decoration: const InputDecoration(hintText: '••••••••'),
        ),
      ]);

  Future<void> _changePassword() async {
    final current = _curPwCtrl.text;
    final next = _newPwCtrl.text;
    final confirm = _confPwCtrl.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => _passwordError = 'Please fill in all three password fields.');
      return;
    }
    if (next != confirm) {
      setState(() => _passwordError = 'New password and confirmation do not match.');
      return;
    }

    setState(() { _savingPassword = true; _passwordError = null; });
    final res = await updateProfile(
      currentPassword: current,
      password: next,
      passwordConfirmation: confirm,
    );
    if (!mounted) return;
    setState(() => _savingPassword = false);

    if (res.success) {
      await AppState.instance.updateCurrentPassword(next);
      _curPwCtrl.clear();
      _newPwCtrl.clear();
      _confPwCtrl.clear();
      _toast('Password updated.');
    } else {
      setState(() => _passwordError = res.message ?? res.error ?? 'Failed to update password. Please try again.');
    }
  }
}
