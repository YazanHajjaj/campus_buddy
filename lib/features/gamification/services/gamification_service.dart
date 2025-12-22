import '../models/xp_points.dart';
import '../models/badge.dart';
import '../models/achievement.dart';

/// Central interface for gamification-related operations.
/// Implementation is deferred to later phases.
abstract class GamificationService {
  // ---------------- XP ----------------

  /// Returns the current XP state for a user.
  Future<XpPoints> getXp(String uid);

  /// Registers an XP-related action.
  /// The actionKey must match a key from xp_rules.dart.
  Future<void> registerXpAction({
    required String uid,
    required String actionKey,
  });

  // ---------------- Badges ----------------

  /// Returns all badges for a user (locked + unlocked).
  Future<List<Badge>> getBadges(String uid);

  /// Re-evaluates badge unlocks for a user.
  Future<void> evaluateBadges(String uid);

  // ---------------- Achievements ----------------

  /// Returns all achievements for a user.
  Future<List<Achievement>> getAchievements(String uid);

  /// Re-evaluates achievement progress for a user.
  Future<void> evaluateAchievements(String uid);
}