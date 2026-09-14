import 'package:booksbound_app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Apple HIG color palette
  static const Color lightScaffold = Color(0xFFF9F9FB);
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightPrimary = Color(0xFF1C1C1E);
  static const Color accentAmber = Color(0xFFFF9500); // Apple warm amber

  static const Color darkScaffold = Color(0xFF000000); // True OLED black
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkCard = Color(0xFF2C2C2E);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkPrimary = Colors.white;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: accentAmber,
      surface: lightCard,
      error: Color(0xFFFF3B30),
      outline: lightBorder,
    ),
    scaffoldBackgroundColor: lightScaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: lightPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 0.8,
      space: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: "Roboto",
        color: lightPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: "Roboto",
        color: lightPrimary,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontFamily: "Poppins",
        color: lightPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: lightPrimary,
        fontFamily: "Poppins",
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimary,
        side: const BorderSide(color: lightBorder, width: 1),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: accentAmber,
      surface: darkSurface,
      error: Color(0xFFFF453A),
      outline: darkBorder,
    ),
    scaffoldBackgroundColor: darkScaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkScaffold,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 0.8,
      space: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: "Roboto",
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: "Roboto",
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontFamily: "Poppins",
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white70,
        fontFamily: "Poppins",
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: darkBorder, width: 1),
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
  );
}
