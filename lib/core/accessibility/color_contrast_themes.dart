import 'package:flutter/material.dart';

/// Defines color themes used for accessibility.
/// Actual theme application is handled elsewhere.

class ColorContrastThemes {
  const ColorContrastThemes();

  static ThemeData standard(ThemeData base) {
    return base;
  }

  static ThemeData highContrast(ThemeData base) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.black,
        onPrimary: Colors.white,
        background: Colors.white,
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    );
  }
}