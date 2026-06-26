import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2D6F8F);
  static const Color textNavy = Color(0xFF1F2A44);
  static const Color mutedText = Color(0xFF6D7890);
  static const Color softBorder = Color(0xFFD8DEE8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffold = Color(0xFFF5F8FB);
  static const Color softBlue = Color(0xFFEAF4F8);
  static const Color boliviaRed = Color(0xFFD94B45);
  static const Color boliviaYellow = Color(0xFFFFBE3D);
  static const Color boliviaGreen = Color(0xFF138A63);
  static const Color coral = Color(0xFFFF7D6E);

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBFDFE), Color(0xFFEAF4F8), Color(0xFFFFFCF3)],
    stops: [0, 0.58, 1],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF5D9), Color(0xFFFFFFFF)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE7F7EF), Color(0xFFFFFFFF)],
  );

  static const LinearGradient profileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3E1), Color(0xFFEAF7F1), Color(0xFFFFFFFF)],
  );

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF6F8094).withValues(alpha: 0.13),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get liftedShadow => [
    BoxShadow(
      color: const Color(0xFF4D5F72).withValues(alpha: 0.16),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textNavy,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(color: mutedText, letterSpacing: 0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textNavy,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: boliviaRed),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: boliviaYellow,
          foregroundColor: textNavy,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: boliviaGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textNavy,
          side: const BorderSide(color: softBorder),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }
}
