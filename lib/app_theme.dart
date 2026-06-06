import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF00132D);
  static const surface = Color(0xFF1D3557);
  static const surfaceContainer = Color(0xFF032041);
  static const surfaceContainerHigh = Color(0xFF112A4C);
  static const primary = Color(0xFFE63946);
  static const onPrimary = Color(0xFF680011);
  static const secondary = Color(0xFF98CDF2);
  static const onSecondary = Color(0xFF00344C);
  static const tertiary = Color(0xFF9ECFD1);
  static const onSurface = Color(0xFFD5E3FF);
  static const onSurfaceVariant = Color(0xFFE4BEBC);
  static const outline = Color(0xFF5B403F);
  static const error = Color(0xFFFFB4AB);
}

class AppTextStyles {
  static TextStyle displayHp(BuildContext context) => GoogleFonts.sora(
        fontSize: 64,
        fontWeight: FontWeight.w800,
        height: 72 / 64,
        letterSpacing: -0.04 * 64,
        color: AppColors.onSurface,
      );

  static TextStyle headlineLg(BuildContext context) => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  static TextStyle statsMd(BuildContext context) => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 24 / 20,
        color: AppColors.onSurface,
      );

  static TextStyle bodyMd(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle labelCaps(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 16 / 12,
        letterSpacing: 0.1 * 12,
        color: AppColors.onSurfaceVariant,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      tertiary: AppColors.tertiary,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainer,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final base = GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        );
        if (states.contains(WidgetState.selected)) {
          return base.copyWith(color: AppColors.primary);
        }
        return base.copyWith(color: AppColors.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariant, size: 24);
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceContainer,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
      hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
    ),
  );
}
