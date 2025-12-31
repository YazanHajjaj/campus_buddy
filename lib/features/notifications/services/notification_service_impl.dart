import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/notification_payload_helpers.dart';
import '../services/notification_service.dart';
import '../services/firestore_notification_service.dart';
import '../services/local_notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FirestoreNotificationService _firestore;
  final LocalNotificationService _local;

  NotificationServiceImpl({
    required FirestoreNotificationService firestore,
    required LocalNotificationService local,
  })  : _firestore = firestore,
        _local = local;

  /* ───────────────── EVENTS ───────────────── */

  @override
  Future<void> sendEventCreatedNotification({
    required String eventId,
    required String title,
  }) async {
    final payload = NotificationPayload.eventPayload(
      title: 'New event',
      body: title,
      eventId: eventId,
      type: NotificationPayload.eventCreated,
    );

    await _broadcast(payload);
  }

  @override
  Future<void> sendEventReminderNotification({
    required String eventId,
    required String title,
    required Duration timeBeforeStart,
  }) async {
    final payload = NotificationPayload.eventPayload(
      title: 'Event reminder',
      body: title,
      eventId: eventId,
      type: NotificationPayload.eventReminder,
    );

    await _local.scheduleReminder(
      id: eventId.hashCode,
      scheduledAt: DateTime.now().add(timeBeforeStart),
      title: payload['title'],
      body: payload['body'],
      payload: payload,
    );
  }

  /* ───────────────── MENTORSHIP ───────────────── */

  @override
  Future<void> sendMentorshipRequestNotification({
    required String requestId,
    required String studentUid,
    required String mentorUid,
  }) async {
    final payload = NotificationPayload.mentorshipPayload(
      title: 'New mentorship request',
      body: 'A student sent you a mentorship request',
      referenceId: requestId,
      type: NotificationPayload.mentorshipRequestNew,
    );

    await _sendToUser(mentorUid, payload);
  }

  @override
  Future<void> sendMentorshipDecisionNotification({
    required String requestId,
    required String studentUid,
    required bool approved,
  }) async {
    final payload = NotificationPayload.mentorshipPayload(
      title: approved ? 'Request approved' : 'Request rejected',
      body: approved
          ? 'Your mentorship request was approved'
          : 'Your mentorship request was rejected',
      referenceId: requestId,
      type: NotificationPayload.mentorshipRequestDecision,
    );

    await _sendToUser(studentUid, payload);
  }

  @override
  Future<void> sendMentorshipChatMessageNotification({
    required String chatId,
    required String senderUid,
    required String receiverUid,
  }) async {
    final payload = NotificationPayload.mentorshipPayload(
      title: 'New message',
      body: 'You received a new mentorship message',
      referenceId: chatId,
      type: NotificationPayload.mentorshipChatMessage,
    );

    await _sendToUser(receiverUid, payload);
  }

  /* ───────────────── STUDY GROUPS ───────────────── */

  @override
  Future<void> sendStudyGroupCreatedNotification({
    required String groupId,
    required List<String> memberUids,
  }) async {
    final payload = NotificationPayload.studyGroupPayload(
      title: 'Study group created',
      body: 'You were added to a study group',
      groupId: groupId,
      type: NotificationPayload.studyGroupCreated,
    );

    for (final uid in memberUids) {
      await _sendToUser(uid, payload);
    }
  }

  @override
  Future<void> sendStudyGroupMessageNotification({
    required String groupId,
    required String senderUid,
  }) async {
    final payload = NotificationPayload.studyGroupPayload(
      title: 'New group message',
      body: 'A new message was sent in your study group',
      groupId: groupId,
      type: NotificationPayload.studyGroupMessage,
    );

    await _broadcast(payload, excludeUid: senderUid);
  }

  /* ───────────────── GAMIFICATION ───────────────── */

  @override
  Future<void> sendLevelUpNotification({
    required String uid,
    required int newLevel,
  }) async {
    final payload = NotificationPayload.gamificationPayload(
      title: 'Level up!',
      body: 'You reached level $newLevel 🎉',
      type: NotificationPayload.levelUp,
    );

    await _sendToUser(uid, payload);
  }

  @override
  Future<void> sendBadgeUnlockedNotification({
    required String uid,
    required String badgeId,
  }) async {
    final payload = NotificationPayload.gamificationPayload(
      title: 'Badge unlocked',
      body: 'You unlocked a new badge 🏅',
      type: NotificationPayload.badgeUnlocked,
    );

    await _sendToUser(uid, payload);
  }

  /* ───────────────── SYSTEM / ADMIN ───────────────── */

  @override
  Future<void> sendAdminAnnouncement({
    required String title,
    required String body,
  }) async {
    final payload = NotificationPayload.systemPayload(
      title: title,
      body: body,
      type: NotificationPayload.adminAnnouncement,
    );

    await _broadcast(payload);
  }

  @override
  Future<void> sendSystemNotification({
    required String uid,
    required String title,
    required String body,
  }) async {
    final payload = NotificationPayload.systemPayload(
      title: title,
      body: body,
      type: NotificationPayload.featureUpdate,
    );

    await _sendToUser(uid, payload);
  }

  /* ───────────────── INTERNAL HELPERS ───────────────── */

  Future<void> _sendToUser(
      String uid,
      Map<String, dynamic> payload,
      ) async {
    await _firestore.createNotification(
      uid: uid,
      payload: payload,
    );

    await _local.showNotification(
      title: payload['title'],
      body: payload['body'],
      payload: payload,
    );
  }

  Future<void> _broadcast(
      Map<String, dynamic> payload, {
        String? excludeUid,
      }) async {
    final users =
    await FirebaseFirestore.instance.collection('users').get();

    for (final doc in users.docs) {
      if (doc.id == excludeUid) continue;
      await _sendToUser(doc.id, payload);
    }
  }
}