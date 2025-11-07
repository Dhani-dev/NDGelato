import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFFFF2E93);
  static const accentColor = Color(0xFFE50074); // Nuevo color para acentos (p. ej. pink más fuerte)
  static const secondaryColor = Color(0xFFF99D00);
  static const backgroundColor = Color(0xFFF9F9F9);
  static const cardBackgroundColor = Colors.white;
  static const textColor = Color(0xFF1A1A1A);
  static const secondaryTextColor = Color(0xFF757575);

  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
      ),
    );
  }
}