import 'package:flutter/material.dart';

/// PWT design tokens — mirror styles.css :root.
class AppColors {
  AppColors._();

  // Blues (primary brand)
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8); // primary
  static const blue800 = Color(0xFF1E40AF);

  // Ink (text + neutrals)
  static const ink900 = Color(0xFF0B1C3F);
  static const ink800 = Color(0xFF14213D);
  static const ink700 = Color(0xFF1F2A44);
  static const ink600 = Color(0xFF5B6478);
  static const ink500 = Color(0xFF5B6478);
  static const ink400 = Color(0xFF8A93A6);
  static const ink300 = Color(0xFFC2C8D6);

  static const line = Color(0xFFEAECF2);
  static const soft = Color(0xFFF5F7FB);
  static const white = Color(0xFFFFFFFF);
  static const dashBg = Color(0xFFF4F6FB);

  // Accents
  static const green500 = Color(0xFF10B981);
  static const green600 = Color(0xFF059669);
  static const green700 = Color(0xFF0F7A4D);
  static const discount = Color(0xFF16A34A); // discount price / "% OFF"
  static const orange = Color(0xFFF97316); // "New" tag
  static const amber = Color(0xFFB45309);
  static const purple = Color(0xFF6D28D9);
  static const danger = Color(0xFFD4495A);

  // Status badge backgrounds (foreground = matching strong color)
  static const badgeGreenBg = Color(0xFFE7F7EF);
  static const badgeBlueBg = Color(0xFFE6EFFF);
  static const badgeAmberBg = Color(0xFFFFF3DF);
  static const badgePurpleBg = Color(0xFFF1EBFF);
}

/// Corner radii (styles.css --radius-*).
class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

/// 8pt-ish spacing scale.
class AppGap {
  AppGap._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Card / elevation shadows (styles.css --shadow-*).
class AppShadow {
  AppShadow._();
  static const card = [
    BoxShadow(color: Color(0x0A0F1E50), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const lg = [
    BoxShadow(color: Color(0x140F1E50), blurRadius: 30, offset: Offset(0, 14)),
  ];
}
