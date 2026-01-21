import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const _accentBlue = Color(0xFF87CEFA); // Light sky blue for accents and highlights
  static const _seedGreen = Color(0xFF22C55E);
  
  // Text colors
  static const _textPrimary = Colors.black;
  static const _textSecondary = Color(0xFF505050);
  static const _textTertiary = Color(0xFF757575);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentBlue,
      brightness: Brightness.light,
      primary: _accentBlue,
      onPrimary: Colors.white,
      secondary: _seedGreen,
      surface: Colors.white,
      background: Colors.white,
      onBackground: _textPrimary,
      onSurface: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _accentBlue.withOpacity(0.1), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: _textPrimary,
        ),
        iconTheme: IconThemeData(color: _textPrimary),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: _textPrimary),
        bodyMedium: TextStyle(color: _textSecondary),
        bodySmall: TextStyle(color: _textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentBlue.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentBlue),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _accentBlue.withOpacity(0.1),
        selectedColor: _accentBlue,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: _textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // We'll keep the dark theme definition but make it similar to light theme
  // with slightly darker backgrounds to maintain the clean look
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentBlue,
      brightness: Brightness.light, // Using light brightness for cleaner look
      primary: _accentBlue,
      onPrimary: Colors.white,
      secondary: _seedGreen,
      surface: Colors.white,
      background: Colors.white,
      onBackground: _textPrimary,
      onSurface: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _accentBlue.withOpacity(0.1), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: _textPrimary,
        ),
        iconTheme: IconThemeData(color: _textPrimary),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: _textPrimary),
        bodyMedium: TextStyle(color: _textSecondary),
        bodySmall: TextStyle(color: _textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentBlue.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentBlue),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _accentBlue.withOpacity(0.1),
        selectedColor: _accentBlue,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: _textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
