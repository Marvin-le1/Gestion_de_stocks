import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const wine = Color(0xFF6B1D2D);
    const grape = Color(0xFF1F3A5A);
    const cream = Color(0xFFF8F4EC);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: wine,
      primary: wine,
      secondary: grape,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
