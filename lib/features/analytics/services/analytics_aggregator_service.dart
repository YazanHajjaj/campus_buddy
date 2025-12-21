import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles higher-level analytics aggregation that goes beyond
/// simple counts and sums.
class AnalyticsAggregatorService {
  final FirebaseFirestore _firestore;

  AnalyticsAggregatorService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Activity Per Day (Admin)

  /// Returns a map where the key is a date (yyyy-mm-dd)
  /// Activity is derived from user lastLogin timestamps.
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

  // Mentor Workload (Admin)
  /// Returns mentorship workload per mentor.
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

  // Resource Popularity (Admin)
  /// Returns a list of resource IDs ordered by download count.
  /// Used for "most downloaded resources".
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

  // Student Activity Summary (Derived)
  /// Computes total active days for a user within a date range.
  /// This is a derived metric and not stored.
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

    // Since we only track lastLogin, this counts as 1 active day.
    // More detailed tracking can be added later if needed.
    return 1;
  }

  // Helpers
  /// Formats a DateTime into yyyy-mm-dd
  /// Used as a map key for daily aggregation.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}