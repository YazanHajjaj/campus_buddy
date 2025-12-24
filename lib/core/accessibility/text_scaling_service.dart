import 'accessibility_settings.dart';

/// Defines how text scaling preferences are interpreted.
///
/// This is a placeholder service.
/// Real scaling logic is implemented later.

class TextScalingService {
  const TextScalingService();

  /// Returns a multiplier for the given text scale preference.
  ///
  /// Values are indicative only.
  double scaleFor(TextScalePreference preference) {
    switch (preference) {
      case TextScalePreference.small:
        return 0.9;
      case TextScalePreference.normal:
        return 1.0;
      case TextScalePreference.large:
        return 1.2;
      case TextScalePreference.extraLarge:
        return 1.4;
    }
  }
}