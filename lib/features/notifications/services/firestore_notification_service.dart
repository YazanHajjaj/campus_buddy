import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class FirestoreNotificationService implements NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('notifications');

  Future<void> _create({
    required String uid,
    required String title,
    required String body,
    required String type,
  }) async {
    await _collection.add({
      'uid': uid, // ✅ FIXED
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ───── Mentorship ─────

  @override
  Future<void> sendMentorshipRequestNotification({
    required String requestId,
    required String studentUid,
    required String mentorUid,
  }) async {
    await _create(
      uid: mentorUid,
      title: 'New Mentorship Request',
      body: 'A student sent you a mentorship request',
      type: 'mentorship_request',
    );
  }

  @override
  Future<void> sendMentorshipDecisionNotification({
    required String requestId,
    required String studentUid,
    required bool approved,
  }) async {
    await _create(
      uid: studentUid,
      title: approved ? 'Request Approved' : 'Request Rejected',
      body: approved
          ? 'Your mentorship request was approved'
          : 'Your mentorship request was rejected',
      type: 'mentorship_decision',
    );
  }

  @override
  Future<void> sendMentorshipChatMessageNotification({
    required String chatId,
    required String senderUid,
    required String receiverUid,
  }) async {
    await _create(
      uid: receiverUid,
      title: 'New Message',
      body: 'You received a new message',
      type: 'chat',
    );
  }

  // ───── Gamification ─────

  @override
  Future<void> sendLevelUpNotification({
    required String uid,
    required int newLevel,
  }) async {
    await _create(
      uid: uid,
      title: 'Level Up!',
      body: 'You reached level $newLevel',
      type: 'level_up',
    );
  }

  @override
  Future<void> sendBadgeUnlockedNotification({
    required String uid,
    required String badgeId,
  }) async {
    await _create(
      uid: uid,
      title: 'Badge Unlocked',
      body: 'You unlocked a new badge',
      type: 'badge',
    );
  }

  // ───── System ─────

  @override
  Future<void> sendSystemNotification({
    required String uid,
    required String title,
    required String body,
  }) async {
    await _create(
      uid: uid,
      title: title,
      body: body,
      type: 'system',
    );
  }

  // unused (future)
  @override
  Future<void> sendEventCreatedNotification({
    required String eventId,
    required String title,
  }) async {}

  @override
  Future<void> sendEventReminderNotification({
    required String eventId,
    required String title,
    required Duration timeBeforeStart,
  }) async {}

  @override
  Future<void> sendStudyGroupCreatedNotification({
    required String groupId,
    required List<String> memberUids,
  }) async {}

  @override
  Future<void> sendStudyGroupMessageNotification({
    required String groupId,
    required String senderUid,
  }) async {}

  @override
  Future<void> sendAdminAnnouncement({
    required String title,
    required String body,
  }) async {}
}