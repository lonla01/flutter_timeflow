import 'package:flutter/material.dart';

/// Navy palette shared with the Cashflow app. Structural colours (app bar,
/// buttons, selection, focus) should come from here rather than being
/// hard-coded in a screen.
class AppColors {
  AppColors._();

  static const navy900 = Color(0xFF071A3D);
  static const navy800 = Color(0xFF0D2B63);
  static const navy700 = Color(0xFF15417F);
  static const navy600 = Color(0xFF1F55A6);
  static const navy500 = Color(0xFF3572C4);
  static const surface = Color(0xFFF4F6FB);
}

class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navy900, AppColors.navy700, AppColors.navy500],
  );

  static const disabled = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB0B6C2), Color(0xFF9AA1AF)],
  );
}

/// Category colours for the monthly chart: jewel tones that sit well next
/// to the navy, since an all-blue pie chart would be unreadable.
const List<Color> categoryChartColors = [
  Color(0xFF3572C4),
  Color(0xFFC9A227),
  Color(0xFF2E8B74),
  Color(0xFFB0413E),
  Color(0xFF6B4FA0),
  Color(0xFFD97A3E),
  Color(0xFF3E7CB1),
  Color(0xFF8C5B3E),
  Color(0xFFB0568C),
  Color(0xFF5C8A3E),
  Color(0xFF4A5A78),
  Color(0xFF9C7A3C),
];

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy700,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.navy700,
    onPrimary: Colors.white,
    secondary: AppColors.navy500,
    surface: Colors.white,
  );

  final baseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 3,
      indicatorColor: AppColors.navy700.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.navy800 : Colors.grey.shade600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? AppColors.navy800 : Colors.grey.shade500);
      }),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 5),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.navy600, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navy700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy700,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.navy700),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.navy600,
      linearTrackColor: AppColors.navy700.withValues(alpha: 0.1),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy900,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(height: 1.35),
    ).apply(bodyColor: AppColors.navy900, displayColor: AppColors.navy900),
  );
}
