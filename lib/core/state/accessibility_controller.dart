import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityController extends ChangeNotifier {
  bool _highContrast = false;
  String _languageCode = 'en';
  bool _loaded = false;

  /// Whether high-contrast mode is enabled.
  bool get highContrast => _highContrast;

  /// Current app language code (e.g. 'en', 'tr').
  String get languageCode => _languageCode;

  /// Indicates whether preferences have been loaded.
  bool get loaded => _loaded;

  AccessibilityController() {
    _load();
  }

  /// Loads accessibility and language preferences from local storage.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _highContrast = prefs.getBool('high_contrast') ?? false;
    _languageCode = prefs.getString('language_code') ?? 'en';

    _loaded = true;
    notifyListeners();
  }

  /// Enables or disables high-contrast mode and persists the value.
  Future<void> toggleHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', value);
  }

  /// Updates the app language and saves the preference.
  Future<void> setLanguage(String code) async {
    if (code == _languageCode) return;

    _languageCode = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }
}