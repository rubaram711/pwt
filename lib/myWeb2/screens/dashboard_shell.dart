import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/dash_kit.dart';

/// Dashboard layout. Thin wrapper that delegates to the single shared chrome
/// (DashScaffold in dash_kit.dart) so every dashboard page — individual and
/// company — uses one identical header + sidebar, exactly like the HTML's
/// shared dash-shell.js. The account type (read from AppState) picks the nav.
class DashboardShell extends StatelessWidget {
  final String active; // 'devices' | 'orders' | 'maintenance' | 'invoices' | 'settings' | 'profile'
  final Widget child;
  /// Force a persona's chrome. Company-only pages pass `true` so they always
  /// render the company sidebar (mirrors dash-shell.js inferring company from
  /// the page). Shared pages (invoices/settings/profile) leave this null and
  /// adapt to the signed-in account.
  final bool? isCompany;
  const DashboardShell({super.key, required this.active, required this.child, this.isCompany});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) => DashScaffold(
        active: active,
        isCompany: isCompany ?? AppState.instance.isCompany,
        child: child,
      ),
    );
  }
}

/// Page header row used at the top of each dashboard page.
class DashHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final List<String>? crumbs;
  const DashHeader({super.key, required this.title, this.subtitle, this.action, this.crumbs});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (crumbs != null) ...[
        Row(children: [
          Text(crumbs!.first, style: AppText.muted.copyWith(color: AppColors.blue700)),
          ...crumbs!.skip(1).map((c) => Text('  ›  $c', style: AppText.muted)),
        ]),
        const SizedBox(height: 12),
      ],
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.pageTitle),
          if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: AppText.muted)],
        ])),
        if (action != null) action!,
      ]),
      const SizedBox(height: 22),
    ]);
  }
}

/// White rounded dashboard card with optional header row.
class DashCard extends StatelessWidget {
  final String? title;
  final Widget? action;
  final Widget child;
  final EdgeInsets padding;
  const DashCard({super.key, this.title, this.action, required this.child, this.padding = const EdgeInsets.all(22)});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.line), boxShadow: AppShadow.card),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Row(children: [Expanded(child: Text(title!, style: AppText.h3)), if (action != null) action!]),
          const SizedBox(height: 16),
        ],
        child,
      ]),
    );
  }
}
