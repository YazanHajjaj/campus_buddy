import 'package:flutter/widgets.dart';
/// AppLocalizations defines how localized strings are accessed
/// throughout the application.
///
/// IMPORTANT:
/// - This file documents the localization contract
/// - Actual string resolution is implemented later
/// - UI must never hardcode user-facing text
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    ) ??
        const AppLocalizations(Locale('en'));
  }

  String text(String key) {
    return key;
  }
}