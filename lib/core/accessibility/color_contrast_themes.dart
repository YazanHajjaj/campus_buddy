import 'package:flutter/material.dart';

/// Color contrast theme variants used for accessibility.
class ColorContrastThemes {
  const ColorContrastThemes();

  /// Standard theme (no contrast changes).
  static ThemeData standard(ThemeData base) {
    return base;
  }

  /// High-contrast theme for improved readability.
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