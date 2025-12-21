import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student_analytics.dart';
import '../models/admin_stats.dart';
import '../models/usage_metrics.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Aggregates analytics data for a single student.
  /// All values are derived from existing collections.
  Future<StudentAnalytics> getStudentAnalytics(String uid) async {
    // Resources uploaded by the student
    final resourcesSnapshot = await _firestore
        .collection('resources')
        .where('uploaderUserId', isEqualTo: uid)
        .get();

    final int resourcesUploadedCount = resourcesSnapshot.size;

    // Event RSVPs
    final eventsSnapshot = await _firestore.collection('events').get();
    int eventsRsvpCount = 0;
    DateTime? lastRsvpAt;

    for (final eventDoc in eventsSnapshot.docs) {
      final rsvpDoc = await _firestore
          .collection('events')
          .doc(eventDoc.id)
          .collection('rsvps')
          .doc(uid)
          .get();

      if (!rsvpDoc.exists) continue;

      eventsRsvpCount++;

      final createdAt = rsvpDoc.data()?['createdAt'];
      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        if (lastRsvpAt == null || date.isAfter(lastRsvpAt!)) {
          lastRsvpAt = date;
        }
      }
    }

    // Mentorship sessions
    final mentorshipSnapshot = await _firestore
        .collection('mentorship_sessions')
        .where('studentId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .get();

    int mentorshipSessionsCount = mentorshipSnapshot.size;
    double mentorshipHoursTotal = 0;
    DateTime? mentorshipLastSessionAt;

    for (final doc in mentorshipSnapshot.docs) {
      final data = doc.data();

      final durationMinutes = data['durationMinutes'];
      if (durationMinutes is num) {
        mentorshipHoursTotal += durationMinutes / 60;
      }

      final completedAt = data['completedAt'];
      if (completedAt is Timestamp) {
        final date = completedAt.toDate();
        if (mentorshipLastSessionAt == null ||
            date.isAfter(mentorshipLastSessionAt!)) {
          mentorshipLastSessionAt = date;
        }
      }
    }

    // User activity
    final userDoc = await _firestore.collection('users').doc(uid).get();
    DateTime? lastActiveAt;

    if (userDoc.exists) {
      final lastLogin = userDoc.data()?['lastLogin'];
      if (lastLogin is Timestamp) {
        lastActiveAt = lastLogin.toDate();
      }
    }

    final usageMetrics = UsageMetrics(
      resourceViews: 0,
      resourceDownloads: 0,
      mentorshipMessagesSent: 0,
      mentorshipSessionsCompleted: mentorshipSessionsCount,
      eventsAttended: eventsRsvpCount,
      studyGroupsJoined: 0,
      lastActiveAt: lastActiveAt,
      totalActiveDays: 0,
    );

    return StudentAnalytics(
      userId: uid,
      usageMetrics: usageMetrics,
      mentorshipSessionsCount: mentorshipSessionsCount,
      mentorshipHoursTotal: mentorshipHoursTotal,
      mentorshipLastSessionAt: mentorshipLastSessionAt,
      eventsRsvpCount: eventsRsvpCount,
      eventsLastRsvpAt: lastRsvpAt,
      resourcesUploadedCount: resourcesUploadedCount,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Aggregates system-wide analytics for admins.
  Future<AdminStats> getAdminStats() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final usersSnapshot = await _firestore.collection('users').get();

    int activeUsersLast7Days = 0;
    int activeUsersLast30Days = 0;

    for (final doc in usersSnapshot.docs) {
      final lastLogin = doc.data()['lastLogin'];
      if (lastLogin is! Timestamp) continue;

      final date = lastLogin.toDate();
      if (date.isAfter(sevenDaysAgo)) activeUsersLast7Days++;
      if (date.isAfter(thirtyDaysAgo)) activeUsersLast30Days++;
    }

    final mentorshipSnapshot = await _firestore
        .collection('mentorship_sessions')
        .where('status', isEqualTo: 'completed')
        .get();

    double totalMentorshipHours = 0;

    for (final doc in mentorshipSnapshot.docs) {
      final durationMinutes = doc.data()['durationMinutes'];
      if (durationMinutes is num) {
        totalMentorshipHours += durationMinutes / 60;
      }
    }

    final eventsSnapshot = await _firestore.collection('events').get();
    int totalEventRsvps = 0;

    for (final eventDoc in eventsSnapshot.docs) {
      final rsvpsSnapshot = await _firestore
          .collection('events')
          .doc(eventDoc.id)
          .collection('rsvps')
          .get();

      totalEventRsvps += rsvpsSnapshot.size;
    }

    final resourcesSnapshot = await _firestore.collection('resources').get();
    int totalDownloads = 0;
    int totalViews = 0;

    for (final doc in resourcesSnapshot.docs) {
      totalDownloads += (doc.data()['downloadCount'] ?? 0) as int;
      totalViews += (doc.data()['viewCount'] ?? 0) as int;
    }

    return AdminStats(
      totalUsers: usersSnapshot.size,
      activeUsersLast7Days: activeUsersLast7Days,
      activeUsersLast30Days: activeUsersLast30Days,
      totalMentorshipSessions: mentorshipSnapshot.size,
      totalMentorshipHours: totalMentorshipHours,
      totalEvents: eventsSnapshot.size,
      totalEventRsvps: totalEventRsvps,
      totalResources: resourcesSnapshot.size,
      totalResourceDownloads: totalDownloads,
      totalResourceViews: totalViews,
      lastUpdatedAt: now,
    );
  }

  Future<void> logResourceViewed({
    required String uid,
    required String resourceId,
  }) async {
    await _logUsage(
      uid: uid,
      action: 'resource_view',
      metadata: {'resourceId': resourceId},
    );
  }

  Future<void> logResourceDownloaded({
    required String uid,
    required String resourceId,
  }) async {
    await _logUsage(
      uid: uid,
      action: 'resource_download',
      metadata: {'resourceId': resourceId},
    );
  }

  Future<void> logEventRsvp({
    required String uid,
    required String eventId,
  }) async {
    await _logUsage(
      uid: uid,
      action: 'event_rsvp',
      metadata: {'eventId': eventId},
    );
  }

  Future<void> logMentorshipMessage({
    required String uid,
    required String chatId,
  }) async {
    await _logUsage(
      uid: uid,
      action: 'mentorship_message',
      metadata: {'chatId': chatId},
    );
  }

  Future<void> logMentorshipSession({
    required String uid,
    required String sessionId,
    required int durationMinutes,
  }) async {
    await _logUsage(
      uid: uid,
      action: 'mentorship_session_completed',
      metadata: {
        'sessionId': sessionId,
        'durationMinutes': durationMinutes,
      },
    );
  }

  Future<void> logStudyGroupJoined({
    required String uid,
    required String groupId,
  }) async {
    await _logUsage(
      uid: uid,
      action: 'study_group_join',
      metadata: {'groupId': groupId},
    );
  }

  Future<void> _logUsage({
    required String uid,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('usage_logs').add({
        'uid': uid,
        'action': action,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Analytics must never block user flows.
    }
  }
}