import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// Typography — the prototype uses Inter throughout.
class AppText {
  AppText._();
  static TextStyle get pageTitle => GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink900, letterSpacing: -0.4);
  static TextStyle get h2 => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink900, letterSpacing: -0.2);
  static TextStyle get h3 => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink900);
  static TextStyle get cardTitle => GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.ink900);
  static TextStyle get bodyLg => GoogleFonts.inter(fontSize: 16, height: 1.5, color: AppColors.ink600);
  static TextStyle get body => GoogleFonts.inter(fontSize: 14, color: AppColors.ink700);
  static TextStyle get muted => GoogleFonts.inter(fontSize: 12.5, color: AppColors.ink500);
  static TextStyle get label => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink700);
  static TextStyle get price => GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.ink900);
  static TextStyle headline(double size) => GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w800, color: AppColors.ink900, letterSpacing: -1, height: 1.05);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue700,
        primary: AppColors.blue700,
        surface: AppColors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppText.body.copyWith(color: AppColors.ink400),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.blue600, width: 1.5),
        ),
      ),
    );
  }
}
