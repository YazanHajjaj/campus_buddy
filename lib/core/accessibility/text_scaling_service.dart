import 'accessibility_settings.dart';

/// Maps text scale preferences to scale factors.
class TextScalingService {
  const TextScalingService();

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