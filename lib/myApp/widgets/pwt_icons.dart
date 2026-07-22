// Icon mapping. The prototype hand-drew SVG glyphs (the `I` object in
// shared.jsx); here each maps to its closest Material icon so the app stays
// idiomatic and weight-consistent. The custom AED dirham mark is rendered from
// the embedded SVG.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/embedded_images.dart';
import '../core/tokens.dart';

class PwtIcons {
  PwtIcons._();

  static const IconData bell = Icons.notifications_outlined;
  static const IconData cube = Icons.inventory_2_outlined;
  static const IconData drop = Icons.water_drop_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData back = Icons.chevron_left;
  static const IconData caret = Icons.chevron_right;
  static const IconData caretDown = Icons.expand_more;
  static const IconData arrow = Icons.arrow_forward;
  static const IconData check = Icons.check;
  static const IconData close = Icons.close;
  static const IconData plus = Icons.add;
  static const IconData minus = Icons.remove;
  static const IconData info = Icons.info_outline;
  static const IconData warn = Icons.warning_amber_rounded;
  static const IconData search = Icons.search;
  static const IconData user = Icons.person_outline;
  static const IconData orders = Icons.receipt_long_outlined;
  static const IconData logout = Icons.logout;
  static const IconData card = Icons.credit_card_outlined;
  static const IconData pin = Icons.place_outlined;
  static const IconData cal = Icons.calendar_today_outlined;
  static const IconData wrench = Icons.build_outlined;
  static const IconData globe = Icons.language;
  static const IconData shield = Icons.verified_user_outlined;
  static const IconData briefcase = Icons.work_outline;
  static const IconData edit = Icons.edit_outlined;
  static const IconData wifi = Icons.wifi;
  static const IconData refresh = Icons.refresh;
  static const IconData building = Icons.apartment_outlined;
  static const IconData bolt = Icons.bolt_outlined;
  static const IconData message = Icons.chat_bubble_outline;
  static const IconData more = Icons.more_horiz;
  static const IconData sun = Icons.light_mode_outlined;
  static const IconData moon = Icons.dark_mode_outlined;
  static const IconData file = Icons.description_outlined;
  static const IconData lock = Icons.lock_outline;
  static const IconData trash = Icons.delete_outline;
  static const IconData truck = Icons.local_shipping_outlined;
  static const IconData sort = Icons.swap_vert;
  static const IconData star = Icons.star;
  static const IconData starLine = Icons.star_border;
  static const IconData cart = Icons.shopping_cart_outlined;
  static const IconData google = Icons.g_mobiledata; // placeholder brand mark
}

/// The AED dirham symbol, drawn from the embedded SVG. Inline-sized to sit
/// next to numerals like the prototype's `<Dh/>`.
class Dirham extends StatelessWidget {
  const Dirham({super.key, this.size = 12, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? PwtColors.textPri;
    return SvgPicture.memory(
      EmbeddedImages.dirham,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}

/// Convenience: "<dirham> 280" inline price chip.
class PriceText extends StatelessWidget {
  const PriceText(
    this.amount, {
    super.key,
    this.style,
    this.symbolSize = 13,
    this.color,
  });

  final String amount;
  final TextStyle? style;
  final double symbolSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? style?.color ?? PwtColors.textPri;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Dirham(size: symbolSize, color: c),
        ),
        Text(amount, style: style),
      ],
    );
  }
}
