import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsService {
  final FirebaseFirestore _db;

  AdminAnalyticsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<int> _count(String collection) async {
    final snap = await _db.collection(collection).count().get();
    return snap.count ?? 0;
  }

  Future<AdminAnalyticsData> load() async {
    final results = await Future.wait([
      _count('users'),
      _count('resources'),
      _count('events'),
      _count('mentorship_sessions'),
      _count('study_groups'),
    ]);

    return AdminAnalyticsData(
      totalUsers: results[0],
      totalResources: results[1],
      totalEvents: results[2],
      totalMentorshipSessions: results[3],
      totalStudyGroups: results[4],
    );
  }
}

/* ───────────────── DATA MODEL ───────────────── */

class AdminAnalyticsData {
  final int totalUsers;
  final int totalResources;
  final int totalEvents;
  final int totalMentorshipSessions;
  final int totalStudyGroups;

  const AdminAnalyticsData({
    required this.totalUsers,
    required this.totalResources,
    required this.totalEvents,
    required this.totalMentorshipSessions,
    required this.totalStudyGroups,
  });
}