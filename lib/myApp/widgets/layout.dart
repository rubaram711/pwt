// Shared layout helpers used across detail/overlay screens: Section, SummaryRow,
// PwtSwitch, DetailScaffold (top bar + scroll body), and a confirm bottom sheet.

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import 'chrome.dart';
import 'primitives.dart';
import 'pwt_icons.dart';

/// A titled section block (eyebrow heading + content) with screen margins.
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow(title)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A label/value row used in order + quote summaries.
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value, this.bold = false, this.last = false});
  final String label;
  final Widget value;
  final bool bold;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: PwtColors.hairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 14) : PwtType.label(color: PwtColors.textSec)),
          DefaultTextStyle.merge(
            style: bold ? PwtType.label(weight: FontWeight.w700).copyWith(fontSize: 15) : PwtType.label(weight: FontWeight.w600),
            child: value,
          ),
        ],
      ),
    );
  }
}

/// iOS-style toggle.
class PwtSwitch extends StatelessWidget {
  const PwtSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: PwtMotion.fast,
        width: 46,
        height: 28,
        decoration: BoxDecoration(
          color: value ? PwtColors.brand : PwtColors.hairline2,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: PwtMotion.fast,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x590F172A), blurRadius: 3, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard detail screen: a [PwtTopBar] over a scrolling body, with an
/// optional sticky bottom action bar.
class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    this.title,
    required this.body,
    this.bottomBar,
    this.onBack,
  });

  final String? title;
  final Widget body;
  final Widget? bottomBar;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PwtColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            PwtTopBar(title: title, onBack: onBack ?? () => Navigator.of(context).maybePop()),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: const BoxDecoration(
                  color: PwtColors.bg,
                  border: Border(top: BorderSide(color: PwtColors.hairline)),
                ),
                child: bottomBar,
              ),
            ),
    );
  }
}

/// A success state (big check, title, body, optional detail card).
class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    required this.title,
    required this.body,
    this.icon = PwtIcons.check,
    this.accent = PwtColors.success,
    this.detail,
  });
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final Widget? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: accent),
          ),
          const SizedBox(height: 18),
          Text(title, style: PwtType.title()),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: PwtType.body(color: PwtColors.textSec)),
          if (detail != null) ...[const SizedBox(height: 24), detail!],
        ],
      ),
    );
  }
}

/// Bottom-sheet confirmation dialog (destructive). Returns true if confirmed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String keepLabel,
  required String confirmLabel,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: PwtColors.scrim,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: PwtColors.bgElev,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: PwtColors.hairline2, borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: PwtColors.error.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(PwtIcons.warn, size: 22, color: PwtColors.error),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: PwtType.subtitle().copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(body, style: PwtType.body(color: PwtColors.textSec).copyWith(fontSize: 13.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: PwtButton(label: keepLabel, variant: PwtButtonVariant.ghost, full: true, onPressed: () => Navigator.pop(ctx, false))),
              const SizedBox(width: 10),
              Expanded(child: PwtButton(label: confirmLabel, variant: PwtButtonVariant.destructive, full: true, onPressed: () => Navigator.pop(ctx, true))),
            ],
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}
