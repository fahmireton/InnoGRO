import 'package:flutter/material.dart';

class AppColors {
  // Primary green
  static const primary = Color(0xFF2D5A3D);
  static const primaryLight = Color(0xFF3D7A52);

  // Success (green accent)
  static const accent = Color(0xFF52B788);
  static const accentLight = Color(0xFFDCFCE7);

  // Semantic
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFFF3CD);
  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFEE2E2);

  // Backgrounds — light
  static const bg = Color(0xFFF7F6F2);
  static const secondary = Color(0xFFF0EFE9);
  static const card = Colors.white;

  // Text — light
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF888888);

  // Border — light
  static const border = Color(0xFFE5E5E0);
  static const divider = Color(0xFFEEEEEE);

  // Shadows
  static const cardShadow = Color(0x0F000000);
  static const shadowLg = Color(0x1A000000);

  // Dark mode
  static const darkBg = Color(0xFF0D1A10);
  static const darkCard = Color(0xFF162318);
  static const darkSecondary = Color(0xFF1E2E20);
  static const darkBorder = Color(0xFF2A3D2C);
  static const darkTextPrimary = Color(0xFFEEEEEE);
  static const darkTextSecondary = Color(0xFF9A9A9A);
}

extension AppTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppColors.darkBg : AppColors.bg;
  Color get card => isDark ? AppColors.darkCard : Colors.white;
  Color get secondary => isDark ? AppColors.darkSecondary : AppColors.secondary;
  Color get border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
}

// ios-shadow: 0 1px 2px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.06)
List<BoxShadow> get iosShadow => [
  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
];

// ios-shadow-lg: 0 2px 4px rgba(0,0,0,0.05), 0 20px 50px rgba(0,0,0,0.1)
List<BoxShadow> get iosShadowLg => [
  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
  BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 50, offset: const Offset(0, 20)),
];

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.darkCard,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: Color(0xFFEEEEEE),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
  );
}
