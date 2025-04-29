import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(
      0xFFEFFAF9,
    ), // Soft off-white teal tone
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00BFA6), // Teal Green
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF00BFA6), // Teal Green
      secondary: const Color(0xFFB2F5EA), // Minty accent
      onPrimary: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00BFA6),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1E2F), // Charcoal Gray
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00BFA6), // Teal Green
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF00BFA6), // Teal Green
      secondary: const Color(0xFFB2F5EA), // Mint Accent
      onPrimary: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00BFA6),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
