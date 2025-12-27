abstract class NotificationService {
  Future<void> sendEventCreatedNotification({
    required String eventId,
    required String title,
  });

  Future<void> sendEventReminderNotification({
    required String eventId,
    required String title,
    required Duration timeBeforeStart,
  });

  Future<void> sendMentorshipRequestNotification({
    required String requestId,
    required String studentUid,
    required String mentorUid,
  });

  Future<void> sendMentorshipDecisionNotification({
    required String requestId,
    required String studentUid,
    required bool approved,
  });

  Future<void> sendMentorshipChatMessageNotification({
    required String chatId,
    required String senderUid,
    required String receiverUid,
  });

  Future<void> sendStudyGroupCreatedNotification({
    required String groupId,
    required List<String> memberUids,
  });

  Future<void> sendStudyGroupMessageNotification({
    required String groupId,
    required String senderUid,
  });

  Future<void> sendLevelUpNotification({
    required String uid,
    required int newLevel,
  });

  Future<void> sendBadgeUnlockedNotification({
    required String uid,
    required String badgeId,
  });

  Future<void> sendAdminAnnouncement({
    required String title,
    required String body,
  });

  Future<void> sendSystemNotification({
    required String uid,
    required String title,
    required String body,
  });
}