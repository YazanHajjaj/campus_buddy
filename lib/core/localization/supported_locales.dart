import 'package:flutter/material.dart';

/// Defines all supported locales for the app.
///
/// Rules:
/// - Add new locales here only
/// - Locale order matters (first = default)
/// - RTL support is handled at UI level
///
/// This file contains configuration only.

class SupportedLocales {
  // Default language
  static const Locale english = Locale('en');

  // Secondary language
  static const Locale turkish = Locale('tr');

  // Future / optional
  static const Locale arabic = Locale('ar');

  /// All locales supported by the app
  static const List<Locale> all = [
    english,
    turkish,
    arabic,
  ];
}