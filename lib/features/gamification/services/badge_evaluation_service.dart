import '../models/badge.dart';
import '../models/achievement.dart';

/// Handles evaluation of badges and achievements.
/// Actual evaluation logic is implemented in later phases.
abstract class BadgeEvaluationService {
  /// Evaluates badge unlocks for a user.
  /// Returns the updated badge list.
  Future<List<Badge>> evaluateBadges(String uid);

  /// Evaluates achievement progress for a user.
  /// Returns the updated achievement list.
  Future<List<Achievement>> evaluateAchievements(String uid);
}