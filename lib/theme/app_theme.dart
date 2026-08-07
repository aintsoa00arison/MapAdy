import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get cyberNoirTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
      ),
      
      // Typographie "Anybody" style
      fontFamily: 'Anybody',
      
      textTheme: const TextTheme(
        // Titles & Identity: Extra-Bold / Expanded, uppercase
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
        // Interface & Data: Medium / Semi-Condensed, uppercase
        labelLarge: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Bottom Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background.withValues(alpha: 0.8),
        indicatorColor: AppColors.secondary,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.background);
          }
          return const IconThemeData(color: AppColors.primary);
        }),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        trackHeight: 2,
      ),

      // Switch Theme (Track Magenta translucide, Thumb Cyan)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.white.withValues(alpha: 0.4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary.withValues(alpha: 0.5);
          return Colors.white.withValues(alpha: 0.1);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return Colors.white.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  // Custom HUD Border Decoration (Simple border)
  static BoxDecoration get hudDecoration => BoxDecoration(
    color: Colors.black.withValues(alpha: 0.5),
    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
  );

  // Neon Glow Decoration (For the main containers)
  static BoxDecoration get neonDecoration => BoxDecoration(
    color: Colors.black.withValues(alpha: 0.8),
    border: Border.all(color: AppColors.primary, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );

  // Profile Image & Settings Button Decoration with Glow and Black background
  static BoxDecoration get profileImageDecoration => BoxDecoration(
    color: Colors.black,
    border: Border.all(color: AppColors.primary, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.5),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );

  // Custom Glow effect for active elements (Magenta)
  static BoxDecoration get activeGlowDecoration => BoxDecoration(
    color: AppColors.secondary.withValues(alpha: 0.1),
    border: Border.all(color: AppColors.secondary, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.secondary.withValues(alpha: 0.4),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ],
  );
}
