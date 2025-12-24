/// NotificationService defines the contract for sending notifications.
abstract class NotificationService {
  // Events

  /// Notify users about a newly created event.
  Future<void> sendEventCreatedNotification({
    required String eventId,
    required String title,
  });

  /// Send a reminder before an event starts.
  Future<void> sendEventReminderNotification({
    required String eventId,
    required String title,
    required Duration timeBeforeStart,
  });

  // Mentorship

  /// Notify a mentor about a new mentorship request.
  Future<void> sendMentorshipRequestNotification({
    required String requestId,
    required String studentUid,
    required String mentorUid,
  });

  /// Notify a student about request approval or rejection.
  Future<void> sendMentorshipDecisionNotification({
    required String requestId,
    required String studentUid,
    required bool approved,
  });

  /// Notify users about a new chat message.
  /// Message content MUST NOT be included.
  Future<void> sendMentorshipChatMessageNotification({
    required String chatId,
    required String senderUid,
    required String receiverUid,
  });

  // Study Groups

  /// Notify members when a new study group is created.
  Future<void> sendStudyGroupCreatedNotification({
    required String groupId,
    required List<String> memberUids,
  });

  /// Notify members about a new study group message.
  Future<void> sendStudyGroupMessageNotification({
    required String groupId,
    required String senderUid,
  });
  // Gamification

  /// Notify a user when they level up.
  Future<void> sendLevelUpNotification({
    required String uid,
    required int newLevel,
  });

  /// Notify a user when a badge is unlocked.
  Future<void> sendBadgeUnlockedNotification({
    required String uid,
    required String badgeId,
  });


  // Admin / System

  /// Send a global admin announcement.
  Future<void> sendAdminAnnouncement({
    required String title,
    required String body,
  });

  /// Send a system notification to a single user.
  Future<void> sendSystemNotification({
    required String uid,
    required String title,
    required String body,
  });
}