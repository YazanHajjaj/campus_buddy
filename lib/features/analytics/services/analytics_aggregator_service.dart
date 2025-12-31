import 'package:cloud_firestore/cloud_firestore.dart';

/// Aggregates higher-level analytics data.
/// Used by admin dashboards and reports.
/// Contains derived metrics only (no UI, no caching).
class AnalyticsAggregatorService {
  final FirebaseFirestore _firestore;

  AnalyticsAggregatorService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ───────────────── DAILY ACTIVITY (ADMIN) ─────────────────

  /// Returns daily active user counts based on `lastLogin`.
  /// Key format: yyyy-mm-dd
  Future<Map<String, int>> getDailyActiveUsers({
    required DateTime start,
    required DateTime end,
  }) async {
    final usersSnapshot = await _firestore.collection('users').get();
    final Map<String, int> dailyActivity = {};

    for (final doc in usersSnapshot.docs) {
      final lastLogin = doc.data()['lastLogin'];
      if (lastLogin is! Timestamp) continue;

      final date = lastLogin.toDate();
      if (date.isBefore(start) || date.isAfter(end)) continue;

      final key = _formatDate(date);
      dailyActivity[key] = (dailyActivity[key] ?? 0) + 1;
    }

    return dailyActivity;
  }

  // ───────────────── MENTOR WORKLOAD (ADMIN) ─────────────────

  /// Returns completed mentorship session count per mentor.
  /// Key: mentorId
  /// Value: number of completed sessions
  Future<Map<String, int>> getMentorWorkload() async {
    final sessionsSnapshot = await _firestore
        .collection('mentorship_sessions')
        .where('status', isEqualTo: 'completed')
        .get();

    final Map<String, int> workload = {};

    for (final doc in sessionsSnapshot.docs) {
      final mentorId = doc.data()['mentorId'];
      if (mentorId is String) {
        workload[mentorId] = (workload[mentorId] ?? 0) + 1;
      }
    }

    return workload;
  }

  // ───────────────── RESOURCE POPULARITY (ADMIN) ─────────────────

  /// Returns resource IDs ordered by download count.
  /// Used for "most downloaded resources" analytics.
  Future<List<String>> getMostDownloadedResources({
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('resources')
        .orderBy('downloadCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // ───────────────── STUDENT ACTIVITY (DERIVED) ─────────────────

  /// Computes active days for a student within a date range.
  /// Based only on `lastLogin` (derived, not stored).
  Future<int> getStudentActiveDays({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final lastLogin = userDoc.data()?['lastLogin'];

    if (lastLogin is! Timestamp) return 0;

    final date = lastLogin.toDate();
    if (date.isBefore(start) || date.isAfter(end)) return 0;

    // With current data, lastLogin counts as one active day.
    return 1;
  }

  // ───────────────── HELPERS ─────────────────

  /// Formats DateTime as yyyy-mm-dd.
  /// Used as a stable key for daily aggregation.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}