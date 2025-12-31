import '../../notifications/services/notification_service.dart';

/// Handles notifications related to gamification events.
///
/// IMPORTANT:
/// - Does NOT calculate XP, levels, or ranks
/// - Does NOT translate text
/// - Only reacts to already-computed gamification results
class GamificationNotificationService {
  final NotificationService _notifications;

  GamificationNotificationService(this._notifications);

  /* ───────── LEVEL UP ───────── */

  /// Notify user when they reach a new level
  Future<void> notifyLevelUp({
    required String uid,
    required int newLevel,
  }) async {
    await _notifications.sendLevelUpNotification(
      uid: uid,
      newLevel: newLevel,
    );
  }

  /* ───────── BADGE UNLOCKED ───────── */

  /// Notify user when a badge is unlocked
  Future<void> notifyBadgeUnlocked({
    required String uid,
    required String badgeId,
  }) async {
    await _notifications.sendBadgeUnlockedNotification(
      uid: uid,
      badgeId: badgeId,
    );
  }

  /* ───────── RANK IMPROVEMENT ───────── */

  /// Notify user when their leaderboard rank improves
  /// Only fires if rank actually improves
  Future<void> notifyRankImproved({
    required String uid,
    required int oldRank,
    required int newRank,
  }) async {
    if (newRank >= oldRank) return;

    await _notifications.sendSystemNotification(
      uid: uid,
      title: 'Rank Improved',
      body: 'You reached rank #$newRank on the leaderboard',
    );
  }

  /* ───────── LEADERBOARD MILESTONE ───────── */

  /// Notify user when entering a leaderboard milestone (e.g. top 10)
  Future<void> notifyLeaderboardMilestone({
    required String uid,
    required int rank,
  }) async {
    await _notifications.sendSystemNotification(
      uid: uid,
      title: 'Leaderboard Milestone',
      body: 'You entered the top $rank players',
    );
  }
}