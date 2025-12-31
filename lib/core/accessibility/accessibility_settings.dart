/// User accessibility preferences.
///
/// Defines which accessibility options are available.
/// Actual behavior is handled by theme and text-scaling layers.
class AccessibilitySettings {
  /// Enables high-contrast theme.
  final bool highContrastEnabled;

  /// Preferred text scaling level.
  final TextScalePreference textScale;

  const AccessibilitySettings({
    required this.highContrastEnabled,
    required this.textScale,
  });

  /// Default values used on first launch.
  static const AccessibilitySettings defaults = AccessibilitySettings(
    highContrastEnabled: false,
    textScale: TextScalePreference.normal,
  );
}

/// Logical text scale options selected by the user.
///
/// Mapped to real scale factors elsewhere.
enum TextScalePreference {
  small,
  normal,
  large,
  extraLarge,
}