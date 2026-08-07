import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // Dark background (Noir bleuté très sombre)
  static const Color background = Color(0xFF131318);

  // Primary (Cyber Cyan)
  static const Color primary = Color(0xFF00F0FF);

  // Secondary (Magenta Pulse)
  static const Color secondary = Color(0xFFFFACE8);

  // Surface and Blur effects
  static const Color surface = Color(0x1A00F0FF); // Translucent Cyan for blur containers
  static const Color border = Color(0x8000F0FF);  // 50% opacity Cyan for borders

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% opacity white
}
