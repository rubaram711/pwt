// PWT theme — type scale + Material ThemeData built from the design tokens.

import 'package:flutter/material.dart';
import 'tokens.dart';

/// Named text styles mirroring the prototype's type scale.
/// Use [PwtType.body], etc. Pass `arabic: true` to swap to the Arabic family.
class PwtType {
  PwtType._();

  static String _family(bool arabic) => arabic ? PwtFonts.arabic : PwtFonts.sans;

  static TextStyle display({Color? color, bool arabic = false}) => TextStyle(
        fontFamily: _family(arabic),
        fontSize: 44,
        height: 52 / 44,
        letterSpacing: -1.2,
        fontWeight: FontWeight.w700,
        color: color ?? PwtColors.textPri,
      );

  static TextStyle headline({Color? color, bool arabic = false}) => TextStyle(
        fontFamily: _family(arabic),
        fontSize: 32,
        height: 38 / 32,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w700,
        color: color ?? PwtColors.textPri,
      );

  static TextStyle title({Color? color, bool arabic = false}) => TextStyle(
        fontFamily: _family(arabic),
        fontSize: 22,
        height: 28 / 22,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w700,
        color: color ?? PwtColors.textPri,
      );

  static TextStyle subtitle({Color? color, bool arabic = false}) => TextStyle(
        fontFamily: _family(arabic),
        fontSize: 17,
        height: 1.35,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w600,
        color: color ?? PwtColors.textPri,
      );

  static TextStyle body({Color? color, FontWeight? weight, bool arabic = false}) =>
      TextStyle(
        fontFamily: _family(arabic),
        fontSize: 15,
        height: 22 / 15,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? PwtColors.textPri,
      );

  static TextStyle label({Color? color, FontWeight? weight, bool arabic = false}) =>
      TextStyle(
        fontFamily: _family(arabic),
        fontSize: 13,
        height: 1.4,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? PwtColors.textPri,
      );

  static TextStyle caption({Color? color, bool arabic = false}) => TextStyle(
        fontFamily: _family(arabic),
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: color ?? PwtColors.textTer,
      );

  static TextStyle eyebrow({Color? color, bool arabic = false}) => TextStyle(
        fontFamily: _family(arabic),
        fontSize: 11,
        height: 1.3,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
        color: color ?? PwtColors.textTer,
      );

  static TextStyle mono({double size = 12, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: PwtFonts.mono,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? PwtColors.textPri,
      );
}

/// Builds the app-wide [ThemeData]. [arabic] swaps the default family so the
/// whole tree reflows with Arabic metrics under RTL.
ThemeData buildPwtTheme({bool arabic = false}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
  );

  final colorScheme = const ColorScheme.light(
    primary: PwtColors.brand,
    onPrimary: Colors.white,
    secondary: PwtColors.teal,
    onSecondary: Colors.white,
    surface: PwtColors.surface,
    onSurface: PwtColors.textPri,
    error: PwtColors.error,
    onError: Colors.white,
  );

  final fontFamily = arabic ? PwtFonts.arabic : PwtFonts.sans;

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: PwtColors.bg,
    canvasColor: PwtColors.bg,
    splashColor: PwtColors.brand.withValues(alpha: 0.08),
    highlightColor: PwtColors.brand.withValues(alpha: 0.05),
    dividerColor: PwtColors.hairline,
    textTheme: base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: PwtColors.textPri,
      displayColor: PwtColors.textPri,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: PwtColors.brand,
      selectionColor: PwtColors.brandTint,
      selectionHandleColor: PwtColors.brand,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: PwtColors.textPri),
      titleTextStyle: TextStyle(
        fontFamily: PwtFonts.sans,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: PwtColors.textPri,
      ),
    ),
  );
}
