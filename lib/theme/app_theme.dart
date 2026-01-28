import 'package:flutter/material.dart';

class AppTheme {
  // Modern color palette with new blue
  static const _primaryBlue = Color.fromARGB(255, 128, 205, 244); // New blue color
  static const _secondaryBlue = Color.fromARGB(255, 128, 205, 244); // Slightly darker blue for gradients
  static const _lightBlue = Color.fromARGB(255, 128, 205, 244); // Lighter blue for gradients
  
  // Text colors
  static const _textPrimary = Color(0xFF2D3748); // Dark blue-gray for primary text
  static const _textSecondary = Color(0xFF4A5568); // Medium blue-gray for secondary text
  static const _textTertiary = Color(0xFF718096); // Light blue-gray for tertiary text
  
  // Gradient definitions
  static const primaryGradient = LinearGradient(
    colors: [_primaryBlue, _secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accentGradient = LinearGradient(
    colors: [Color.fromARGB(255, 126, 204, 243), _primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF7FAFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
      primary: _primaryBlue,
      onPrimary: Colors.white,
      secondary: _secondaryBlue,
      tertiary: _lightBlue,
      surface: Colors.white,
      background: Colors.white,
      onBackground: _textPrimary,
      onSurface: _textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFF), // Subtle blue tint for background
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: _primaryBlue.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: _textPrimary,
        ),
        iconTheme: IconThemeData(color: _primaryBlue),
        shadowColor: _primaryBlue.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineSmall: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        titleLarge: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        bodyLarge: TextStyle(color: _textPrimary, letterSpacing: 0.1),
        bodyMedium: TextStyle(color: _textSecondary, letterSpacing: 0.1),
        bodySmall: TextStyle(color: _textTertiary, letterSpacing: 0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _primaryBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _primaryBlue.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _primaryBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: _textTertiary.withOpacity(0.7)),
        errorStyle: const TextStyle(fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryBlue.withOpacity(0.08),
        selectedColor: _primaryBlue,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: _primaryBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide.none,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shadowColor: _primaryBlue.withOpacity(0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: BorderSide(color: _primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  // Modern dark theme with blue accents
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.dark,
      primary: _primaryBlue,
      onPrimary: Colors.white,
      secondary: _secondaryBlue,
      tertiary: _lightBlue,
      surface: const Color(0xFF1A202C),
      background: const Color(0xFF121A29),
      onBackground: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121A29),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A202C),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: _primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A202C).withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: _primaryBlue),
        shadowColor: Colors.black.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        bodyLarge: TextStyle(color: Colors.white, letterSpacing: 0.1),
        bodyMedium: TextStyle(color: Color(0xFFE2E8F0), letterSpacing: 0.1),
        bodySmall: TextStyle(color: Color(0xFFA0AEC0), letterSpacing: 0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D3748),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _primaryBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _primaryBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _primaryBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        errorStyle: const TextStyle(fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryBlue.withOpacity(0.2),
        selectedColor: _primaryBlue,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide.none,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shadowColor: _primaryBlue.withOpacity(0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: BorderSide(color: _primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
  
  // Helper methods for gradients
  static Shader getPrimaryGradient(Rect bounds) {
    return primaryGradient.createShader(bounds);
  }
  
  static Shader getAccentGradient(Rect bounds) {
    return accentGradient.createShader(bounds);
  }
  
  // Helper method for glass effect
  static BoxDecoration getGlassEffect({
    BorderRadius? borderRadius,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.2),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    );
  }
}