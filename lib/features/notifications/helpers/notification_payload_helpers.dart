/// Centralized notification payload definitions.
///
/// This file defines:
/// - Standard payload keys
/// - Locked notification types
/// - Helper builders for consistent payload creation
///
/// This is used by BOTH:
/// - Local notifications (now)
/// - Push notifications (later)
class NotificationPayload {
  /* ───────────────── PAYLOAD KEYS ───────────────── */

  static const String keyTitle = 'title';
  static const String keyBody = 'body';
  static const String keyType = 'type';
  static const String keyReferenceId = 'referenceId';
  static const String keySentAt = 'sentAt';

  /* ───────────────── NOTIFICATION TYPES (LOCKED) ───────────────── */

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
  static const String studyGroupSessionReminder =
      'study_group_session_reminder';

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

  /* ───────────────── BASE BUILDER ───────────────── */

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

  /* ───────────────── EVENT HELPERS ───────────────── */

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

  /* ───────────────── MENTORSHIP HELPERS ───────────────── */

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

  /* ───────────────── STUDY GROUP HELPERS ───────────────── */

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

  /// Study group session reminder payload.
  static Map<String, dynamic> studyGroupSessionPayload({
    required String title,
    required String body,
    required String sessionId,
  }) {
    return buildBasePayload(
      title: title,
      body: body,
      type: studyGroupSessionReminder,
      referenceId: sessionId,
    );
  }

  /* ───────────────── GAMIFICATION HELPERS ───────────────── */

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

  /* ───────────────── SYSTEM / ADMIN HELPERS ───────────────── */

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