import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';

/// KPI summary tile.
class KpiTile extends StatelessWidget {
  final String label, value, sub;
  final IconData? icon;
  final Color iconColor;
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    this.icon,
    this.iconColor = AppColors.blue700,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // never unbounded
        children: [
          Row(children: [
            Expanded(child: Text(label, style: AppText.muted)),
            if (icon != null)
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
          ]),
          const SizedBox(height: 10),
          Text(value, style: AppText.pageTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 4), // FIX: no Spacer() — unbounded height crash
          Text(sub, style: AppText.muted),
        ],
      ),
    );
  }
}

/// Responsive grid of KPI tiles.
class KpiGrid extends StatelessWidget {
  final List<KpiTile> tiles;
  const KpiGrid({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 760
          ? tiles.length.clamp(1, 4)
          : c.maxWidth > 460
          ? 2
          : 1;
      final tileWidth = (c.maxWidth - (cols - 1) * 16) / cols;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: tiles.map((t) => SizedBox(width: tileWidth, child: t)).toList(),
      );
    });
  }
}

/// Vertical progress timeline.
class TimelineStep {
  final String title, sub;
  final bool done, active;
  const TimelineStep(this.title, this.sub, {this.done = false, this.active = false});
}

class Timeline extends StatelessWidget {
  final List<TimelineStep> steps;
  const Timeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final filled = s.done || s.active;
        final color = s.done
            ? AppColors.green600
            : s.active
            ? AppColors.blue700
            : AppColors.ink300;
        // IntrinsicHeight is safe here because this Column has mainAxisSize.min
        // (not inside an unbounded parent). It's needed to stretch the
        // connector line to match whatever height the text takes.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: filled ? color : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                  ),
                  if (i < steps.length - 1)
                    Expanded(child: Container(width: 2, color: s.done ? AppColors.green600 : AppColors.line)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.title,
                          style: AppText.label.copyWith(
                              color: s.active || s.done ? AppColors.ink900 : AppColors.ink500)),
                      const SizedBox(height: 2),
                      Text(s.sub, style: AppText.muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DashTable — the root cause of the invoice crash.
//
// THE PROBLEM:
//   SingleChildScrollView(scrollDirection: Axis.horizontal) gives its child
//   an *unbounded* horizontal constraint.  Any Row inside that uses Expanded
//   immediately crashes with "RenderFlex children have non-zero flex but
//   incoming width constraints are unbounded."
//
// THE FIX:
//   Assign a fixed pixel width to every column instead of using Expanded/flex.
//   The table is already inside a horizontal scroll so fixed widths are fine —
//   the scroll handles overflow naturally.
// ─────────────────────────────────────────────────────────────────────────────

/// Column width spec used by both the header and every data row.
class _Col {
  final double width;
  const _Col(this.width);
}

class DashTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;

  const DashTable({super.key, required this.headers, required this.rows});

  // Fixed widths — first column is wider (invoice number / product name).
  // Adjust these constants if you add/remove columns.
  static List<_Col> _cols(int count) {
    return List.generate(count, (i) => _Col(i == 0 ? 200 : 140));
  }

  @override
  Widget build(BuildContext context) {
    final cols = _cols(headers.length);
    final totalWidth = cols.fold(0.0, (sum, c) => sum + c.width);

    Widget buildRow(List<Widget> cells, {bool isHeader = false}) {
      return SizedBox(
        width: totalWidth,
        child: Row(
          // FIX: mainAxisSize.min + no Expanded = safe inside horizontal scroll
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(cells.length, (i) {
            return SizedBox(
              width: cols[i].width,
              child: Padding(
                padding: EdgeInsets.only(right: 12, bottom: isHeader ? 6 : 0),
                child: cells[i],
              ),
            );
          }),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRow(
              headers.map((h) => Text(h, style: AppText.muted.copyWith(fontWeight: FontWeight.w700))).toList(),
              isHeader: true,
            ),
            const Divider(height: 1, color: AppColors.line),
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: buildRow(r),
            )),
          ],
        ),
      ),
    );
  }
}

/// Product cell used inside dashboard tables.
class ProdCell extends StatelessWidget {
  final String image, name, sub;
  const ProdCell({super.key, required this.image, required this.name, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(9),
          ),
          padding: const EdgeInsets.all(5),
          child: Image.asset(image, fit: BoxFit.contain),
        ),
        const SizedBox(width: 11),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(sub, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}