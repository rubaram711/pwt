import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';

/// Primary / outline / ghost button — mirrors .d-btn / .btn-primary.
enum PwtBtn { primary, outline, ghost, danger }

class PwtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PwtBtn variant;
  final IconData? icon;
  final bool fullWidth;
  const PwtButton(this.label, {super.key, this.onPressed, this.variant = PwtBtn.primary, this.icon, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg, border;
    switch (variant) {
      case PwtBtn.primary: bg = AppColors.blue700; fg = Colors.white; border = AppColors.blue700; break;
      case PwtBtn.outline: bg = Colors.white; fg = AppColors.ink800; border = AppColors.line; break;
      case PwtBtn.ghost: bg = AppColors.blue50; fg = AppColors.blue700; border = AppColors.blue50; break;
      case PwtBtn.danger: bg = Colors.white; fg = AppColors.danger; border = const Color(0xFFF3C9C9); break;
    }
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 8)],
        Text(label, style: AppText.label.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm + 1),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm + 1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm + 1),
              border: Border.all(color: border, width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class HomePwtButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PwtBtn variant;
  final IconData? icon;
  final bool fullWidth;
  const HomePwtButton(this.label, {super.key, this.onPressed, this.variant = PwtBtn.primary, this.icon, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg, border;
    switch (variant) {
      case PwtBtn.primary: bg = AppColors.blue700; fg = Colors.white; border = AppColors.blue700; break;
      case PwtBtn.outline:
        bg = Colors.white;
        fg = icon != null ? AppColors.blue700 : AppColors.ink800;
        border = icon != null ? AppColors.blue200 : AppColors.line;
        break;
      case PwtBtn.ghost: bg = AppColors.blue50; fg = AppColors.blue700; border = AppColors.blue50; break;
      case PwtBtn.danger: bg = Colors.white; fg = AppColors.danger; border = const Color(0xFFF3C9C9); break;
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── أيقونة الـ outline داخل دائرة ──
        if (icon != null && variant == PwtBtn.outline) ...[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: fg, width: 1.5),
            ),
            child: Icon(icon, size: 14, color: fg),
          ),
          const SizedBox(width: 10),
        ]
        // ── أيقونة عادية للباقي ──
        else if (icon != null) ...[
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppText.label.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(50), // pill shape
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: border, width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


/// Status pill — mirrors .badge-st (green / blue / amber / purple).
class StatusBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const StatusBadge(this.text, {super.key, required this.bg, required this.fg});

  factory StatusBadge.green(String t) => StatusBadge(t, bg: AppColors.badgeGreenBg, fg: AppColors.green600);
  factory StatusBadge.blue(String t) => StatusBadge(t, bg: AppColors.badgeBlueBg, fg: AppColors.blue700);
  factory StatusBadge.amber(String t) => StatusBadge(t, bg: AppColors.badgeAmberBg, fg: AppColors.amber);
  factory StatusBadge.purple(String t) => StatusBadge(t, bg: AppColors.badgePurpleBg, fg: AppColors.purple);
  factory StatusBadge.gray(String t) => StatusBadge(t, bg: const Color(0xFFEDEFF4), fg: AppColors.ink500);

  /// Map a free-text status label to the right colour.
  factory StatusBadge.forStatus(String t) {
    final s = t.toLowerCase();
    if (s.contains('cancel')) return StatusBadge.gray(t);
    if (s.contains('quotation') || s.contains('quote')) return StatusBadge.purple(t);
    if (s.contains('process') || s.contains('await') || s.contains('pending') || s.contains('ordered')) return StatusBadge.amber(t);
    if (s.contains('paid') || s.contains('deliver') || s.contains('install') && !s.contains('installing') || s.contains('complete') || s.contains('agreed')) return StatusBadge.green(t);
    return StatusBadge.blue(t);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: AppText.muted.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 11.5)),
      ]),
    );
  }
}

/// White rounded card — mirrors .d-card.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(22), this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadow.card,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.lg), child: card);
  }
}

/// Pill segmented control (account type, buy/rent, inquiry type…).
class Segmented extends StatelessWidget {
  final List<String> options;
  final List<IconData>? icons;
  final int index;
  final ValueChanged<int> onChanged;
  const Segmented({super.key, required this.options, this.icons, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(AppRadius.sm + 2), border: Border.all(color: AppColors.line)),
      child: Row(children: List.generate(options.length, (i) {
        final on = i == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: on ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: on ? AppShadow.card : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icons != null) ...[Icon(icons![i], size: 16, color: on ? AppColors.blue700 : AppColors.ink400), const SizedBox(width: 7)],
                Flexible(child: Text(options[i], overflow: TextOverflow.ellipsis, style: AppText.label.copyWith(color: on ? AppColors.ink900 : AppColors.ink500))),
              ]),
            ),
          ),
        );
      })),
    );
  }
}

/// On/off pill toggle (settings, drawers).
class PwtToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const PwtToggle({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: value ? AppColors.blue700 : AppColors.ink300, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}
