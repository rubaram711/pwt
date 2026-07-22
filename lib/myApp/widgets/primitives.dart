// Reusable primitives ported from proto/shared.jsx: PwtButton, Pill, Eyebrow,
// PwtCard, ListRow, Banner, SegmentRow.

import 'package:flutter/material.dart';
import '../core/tokens.dart';
import '../core/theme.dart';

enum PwtButtonVariant { primary, secondary, ghost, soft, dark, destructive }

enum PwtButtonSize { sm, md, lg }

class PwtButton extends StatelessWidget {
  const PwtButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PwtButtonVariant.primary,
    this.size = PwtButtonSize.lg,
    this.full = false,
    this.icon,
    this.trailing,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PwtButtonVariant variant;
  final PwtButtonSize size;
  final bool full;
  final IconData? icon;
  final IconData? trailing;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final (height, padX, fontSize) = switch (size) {
      PwtButtonSize.sm => (36.0, 14.0, 13.0),
      PwtButtonSize.md => (44.0, 18.0, 14.0),
      PwtButtonSize.lg => (52.0, 22.0, 15.0),
    };

    late final Color bg;
    late final Color fg;
    BoxBorder? border;
    switch (variant) {
      case PwtButtonVariant.primary:
        bg = PwtColors.brand;
        fg = Colors.white;
      case PwtButtonVariant.secondary:
        bg = PwtColors.surface;
        fg = PwtColors.brand;
        border = Border.all(color: PwtColors.brand, width: 1.5);
      case PwtButtonVariant.ghost:
        bg = PwtColors.surface;
        fg = PwtColors.textPri;
        border = Border.all(color: PwtColors.hairline2);
      case PwtButtonVariant.soft:
        bg = PwtColors.brandTint;
        fg = PwtColors.brandDeep;
        border = Border.all(color: PwtColors.brandBorder);
      case PwtButtonVariant.dark:
        bg = PwtColors.textPri;
        fg = PwtColors.bg;
      case PwtButtonVariant.destructive:
        bg = PwtColors.error;
        fg = Colors.white;
    }

    final child = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 4, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Icon(trailing, size: fontSize + 4, color: fg),
        ],
      ],
    );

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(PwtRadius.button),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(PwtRadius.button),
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: padX),
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(PwtRadius.button),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color,
    this.dot = false,
    this.soft = true,
  });

  final String label;
  final Color? color;
  final bool dot;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final c = color ?? PwtColors.brand;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: soft ? c.withValues(alpha: 0.12) : c,
        borderRadius: BorderRadius.circular(PwtRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: soft ? c : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: PwtType.eyebrow(color: color));
  }
}

class PwtCard extends StatelessWidget {
  const PwtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = PwtRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: PwtColors.hairline),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: PwtShadows.e1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
    return card;
  }
}

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.leading,
    required this.title,
    this.sub,
    this.trailing,
    this.danger = false,
    this.onTap,
    this.last = false,
  });

  final IconData? leading;
  final String title;
  final String? sub;
  final Widget? trailing;
  final bool danger;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? PwtColors.error : PwtColors.textPri;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: PwtColors.hairline)),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, size: 20, color: danger ? PwtColors.error : PwtColors.textSec),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: PwtType.label(color: fg, weight: FontWeight.w500).copyWith(fontSize: 14.5)),
                  if (sub != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(sub!, style: PwtType.caption()),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

enum BannerVariant { info, success, warn, error }

class PwtBanner extends StatelessWidget {
  const PwtBanner({
    super.key,
    this.variant = BannerVariant.info,
    this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final BannerVariant variant;
  final String? title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (fill, borderC, fg, icon) = switch (variant) {
      BannerVariant.info => (PwtColors.infoFill, PwtColors.infoBorder, PwtColors.brand, Icons.info_outline),
      BannerVariant.success => (PwtColors.successFill, PwtColors.successBorder, PwtColors.success, Icons.check),
      BannerVariant.warn => (PwtColors.warnFill, PwtColors.warnBorder, PwtColors.warning, Icons.warning_amber_rounded),
      BannerVariant.error => (PwtColors.errorFill, PwtColors.errorBorder, PwtColors.error, Icons.warning_amber_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: borderC),
        borderRadius: BorderRadius.circular(PwtRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(title!, style: PwtType.label(weight: FontWeight.w600).copyWith(fontSize: 13)),
                  ),
                Text(body, style: PwtType.caption(color: PwtColors.textSec).copyWith(fontSize: 12.5, height: 1.45)),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: onAction,
                      child: Text('$action →', style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class SegmentRow<T> extends StatelessWidget {
  const SegmentRow({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? label;
  final T value;
  final List<SegmentOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label!, style: PwtType.label(color: PwtColors.textSec, weight: FontWeight.w500).copyWith(fontSize: 12.5)),
          ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: PwtColors.surface2,
            borderRadius: BorderRadius.circular(PwtRadius.md),
            border: Border.all(color: PwtColors.hairline),
          ),
          child: Row(
            children: [
              for (final o in options)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(o.value),
                    child: AnimatedContainer(
                      duration: PwtMotion.fast,
                      height: 34,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: o.value == value ? PwtColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: o.value == value
                            ? const [BoxShadow(color: Color(0x1F0F172A), blurRadius: 4, offset: Offset(0, 1))]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (o.icon != null) ...[
                            Icon(o.icon, size: 15, color: o.value == value ? PwtColors.textPri : PwtColors.textSec),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            o.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: o.value == value ? FontWeight.w600 : FontWeight.w500,
                              color: o.value == value ? PwtColors.textPri : PwtColors.textSec,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
