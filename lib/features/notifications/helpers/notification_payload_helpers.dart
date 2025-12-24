/// Centralized notification payload definitions.
/// This file defines:
class NotificationPayload {
  // Payload keys (used everywhere)

  static const String keyTitle = 'title';
  static const String keyBody = 'body';
  static const String keyType = 'type';
  static const String keyReferenceId = 'referenceId';
  static const String keySentAt = 'sentAt';

  // Notification types (LOCKED)

  // Events
  static const String eventCreated = 'event_created';
  static const String eventReminder = 'event_reminder';

  // Mentorship
  static const String mentorshipRequestNew =
      'mentorship_request_new';
  static const String mentorshipRequestDecision =
      'mentorship_request_decision';
  static const String mentorshipChatMessage =
      'mentorship_chat_message';

  // Study Groups
  static const String studyGroupCreated =
      'study_group_created';
  static const String studyGroupMessage =
      'study_group_message';

  // Gamification
  static const String levelUp = 'level_up';
  static const String badgeUnlocked = 'badge_unlocked';

  // Admin
  static const String adminAnnouncement =
      'admin_announcement';

  // System
  static const String profileCompletionReminder =
      'profile_completion_reminder';
  static const String featureUpdate = 'feature_update';

  // Helper builders

  /// Base payload builder used by all notifications.
  static Map<String, dynamic> buildBasePayload({
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) {
    return {
      keyTitle: title,
      keyBody: body,
      keyType: type,
      keyReferenceId: referenceId ?? '',
      keySentAt: DateTime.now().toIso8601String(),
    };
  }

  /// Event-related payload helper.
  static Map<String, dynamic> eventPayload({
    required String title,
    required String body,
    required String eventId,
    required String type,
  }) {
    return buildBasePayload(
      title: title,
      body: body,
      type: type,
      referenceId: eventId,
    );
  }

  /// Mentorship-related payload helper.
  static Map<String, dynamic> mentorshipPayload({
    required String title,
    required String body,
    required String referenceId,
    required String type,
  }) {
    return buildBasePayload(
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
    );
  }

  /// Study group-related payload helper.
  static Map<String, dynamic> studyGroupPayload({
    required String title,
    required String body,
    required String groupId,
    required String type,
  }) {
    return buildBasePayload(
      title: title,
      body: body,
      type: type,
      referenceId: groupId,
    );
  }

  /// Gamification-related payload helper.
  static Map<String, dynamic> gamificationPayload({
    required String title,
    required String body,
    required String type,
  }) {
    return buildBasePayload(
      title: title,
      body: body,
      type: type,
    );
  }

  /// Admin / system-level payload helper.
  static Map<String, dynamic> systemPayload({
    required String title,
    required String body,
    required String type,
  }) {
    return buildBasePayload(
      title: title,
      body: body,
      type: type,
    );
  }
}