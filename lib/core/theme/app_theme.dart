import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData defaultTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    primaryColor: const Color(0xFF2446C8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2446C8),
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData highContrastTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
    ),
    dividerColor: Colors.black,
    cardColor: Colors.white,
  );
}