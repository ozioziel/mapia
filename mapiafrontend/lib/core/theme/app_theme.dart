import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color textNavy = Color(0xFF1F2A44);
  static const Color mutedText = Color(0xFF6D7890);
  static const Color softBorder = Color(0xFFD8DEE8);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF3FAFF),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textNavy,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(color: mutedText, letterSpacing: 0),
      ),
    );
  }
}
