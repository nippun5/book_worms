import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brown500,
      primary: AppColors.brown500,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      surface: Colors.white,
      error: AppColors.red,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream50,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brown500,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: AppColors.brown900.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brown500,
          side: const BorderSide(color: AppColors.brown300),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.brown500),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brown500,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.tan100.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brown500, width: 1.6),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.brown500,
        unselectedItemColor: Color(0xFFC9B9A8),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.tan100,
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected) ? AppColors.brown500 : const Color(0xFFB8A794),
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? AppColors.brown500 : const Color(0xFFB8A794),
            )),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.tan100,
        labelStyle: const TextStyle(color: AppColors.brown700, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brown500,
        unselectedLabelColor: AppColors.grayText,
        indicatorColor: AppColors.brown500,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.tan100, thickness: 1),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: AppColors.brown900),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.brown900),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.brown900),
        bodyLarge: TextStyle(color: AppColors.brown700),
        bodyMedium: TextStyle(color: AppColors.brown700),
        bodySmall: TextStyle(color: AppColors.grayText),
      ),
    );
  }
}
