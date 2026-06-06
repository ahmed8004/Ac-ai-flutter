import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryCyan = Color(0xFF00D4FF);
  static const Color primaryDark = Color(0xFF0099CC);

  // Background Colors
  static const Color bgPrimary = Color(0xFF0D0D0D);
  static const Color bgSecondary = Color(0xFF1A1A1A);
  static const Color bgElevated = Color(0xFF252525);

  // Orb State Colors
  static const Color orbIdle = Color(0xFF00D4FF);
  static const Color orbListening = Color(0xFF00FF88);
  static const Color orbProcessing = Color(0xFFFFB800);
  static const Color orbSpeaking = Color(0xFFFF00FF);
  static const Color orbError = Color(0xFFFF3B3B);
  static const Color orbPaused = Color(0xFF666666);
  static const Color orbStopped = Color(0xFF333333);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Button Colors
  static const Color buttonPause = Color(0xFFFFB800);
  static const Color buttonStop = Color(0xFFFF3B3B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: primaryCyan,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryCyan,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: bgElevated,
        foregroundColor: primaryCyan,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  // Shadow Generators
  static List<BoxShadow> getGlow(Color color, double opacity, double radius) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: radius,
        spreadRadius: radius / 3,
      ),
    ];
  }

  // Button Decoration
  static BoxDecoration getButtonDecoration(Color color, double glowOpacity) {
    return BoxDecoration(
      color: bgSecondary.withOpacity(0.8),
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 2),
      boxShadow: getGlow(color, glowOpacity, 20),
    );
  }
}
