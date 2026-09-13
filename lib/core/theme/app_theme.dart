import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    primaryColor: Color(0xFF1E1E1E), // dark charcoal
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF1E1E1E),
      primary: Color(0xFF1E1E1E),
      secondary: Color(0xFFFFC107),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
    ),

    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF9F9F9),
      foregroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: false,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: "Roboto",
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: "Roboto",
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6, fontFamily: "Poppins"),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black,
        fontFamily: "Poppins",
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
