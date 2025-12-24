/// Accessibility-related user preferences.
///
/// This file defines which accessibility options exist.
/// Actual behavior is implemented later.

class AccessibilitySettings {
  final bool highContrastEnabled;
  final TextScalePreference textScale;

  const AccessibilitySettings({
    required this.highContrastEnabled,
    required this.textScale,
  });

  /// Default accessibility settings
  static const AccessibilitySettings defaults = AccessibilitySettings(
    highContrastEnabled: false,
    textScale: TextScalePreference.normal,
  );
}

enum TextScalePreference {
  small,
  normal,
  large,
  extraLarge,
}