// PWT design tokens — single source of truth, ported from the prototype's
// design-system token layer. The shipping app is light-only (dark mode was
// removed in the prototype), so these are the light values.
//
// Naming mirrors the original: brand / surface / text / status + the spacing,
// radius, type and motion scales.

import 'package:flutter/widgets.dart';

/// Brand + semantic colors.
class PwtColors {
  PwtColors._();

  // ── Brand ──
  static const Color brand = Color(0xFF1C4BD0); // approved design-system blue, rgb(28,75,208)
  static const Color brandSoft = Color(0xFF3B82F6);
  static const Color brandDeep = Color(0xFF1E40AF);
  static const Color brandTint = Color(0x141C4BD0); // rgba(28,75,208,0.08)
  static const Color brandBorder = Color(0x4D1C4BD0); // rgba(28,75,208,0.30)
  static const Color teal = Color(0xFF10B981);

  // ── Surfaces ──
  static const Color bg = Color(0xFFFFFFFF); // approved design system: white background
  static const Color bgElev = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF0F3F9);
  static const Color hairline = Color(0x140B1C3F); // rgba(11,28,63,0.08)
  static const Color hairline2 = Color(0x240B1C3F); // rgba(11,28,63,0.14)
  static const Color scrim = Color(0x2E0B1C3F); // rgba(11,28,63,0.18)

  // ── Text ──
  static const Color textPri = Color(0xFF0B1C3F);
  static const Color textSec = Color(0x9E0B1C3F); // 0.62
  static const Color textTer = Color(0x730B1C3F); // 0.45
  static const Color textDis = Color(0x400B1C3F); // 0.25
  static const Color textInv = Color(0xFFFFFFFF);

  // ── Status ──
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD9534B);
  static const Color info = Color(0xFF1C4BD0);

  // Soft status fills/borders used by Banner etc.
  static const Color infoFill = Color(0x1A1C4BD0);
  static const Color infoBorder = Color(0x4D1C4BD0);
  static const Color successFill = Color(0x1A10B981);
  static const Color successBorder = Color(0x4D10B981);
  static const Color warnFill = Color(0x1FE0962A);
  static const Color warnBorder = Color(0x4DE0962A);
  static const Color errorFill = Color(0x1AD9534B);
  static const Color errorBorder = Color(0x4DD9534B);
}

/// Elevation shadows (light mode).
class PwtShadows {
  PwtShadows._();

  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x0F0F172A), // 0.06
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x140F172A), // 0.08
      blurRadius: 40,
      offset: Offset(0, 14),
    ),
  ];
  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x240F172A), // 0.14
      blurRadius: 60,
      offset: Offset(0, 24),
    ),
  ];
  static List<BoxShadow> brandGlow(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: 0.45),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}

/// Spacing scale (px → logical pixels).
class PwtSpace {
  PwtSpace._();
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;
  static const double s80 = 80;

  // Semantic roles
  static const double padCard = 20;
  static const double padComponent = 12;
  static const double gapComponent = 8;
  static const double gapSection = 28;
  static const double screenMargin = 20;
}

/// Corner radii.
class PwtRadius {
  PwtRadius._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 28;
  static const double full = 999;

  // Roles
  static const double input = md;
  static const double button = md;
  static const double card = lg; // prototype cards use 18
  static const double sheet = xxl;
  static const double chip = full;
}

/// Motion — durations + easing curves.
class PwtMotion {
  PwtMotion._();
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration deliberate = Duration(milliseconds: 560);

  static const Cubic standard = Cubic(0.2, 0, 0, 1);
  static const Cubic enter = Cubic(0, 0, 0, 1);
  static const Cubic exit = Cubic(0.3, 0, 1, 1);
  static const Cubic spring = Cubic(0.5, 1.5, 0.5, 1);
}

/// Font families. Loaded as embedded base64 at startup (see embedded_fonts.dart).
/// If the embedded TTFs are absent, these names resolve to the platform's
/// default sans, so the UI still renders.
class PwtFonts {
  PwtFonts._();
  static const String sans = 'Inter';
  static const String arabic = 'IBMPlexSansArabic';
  static const String mono = 'JetBrainsMono';
}
