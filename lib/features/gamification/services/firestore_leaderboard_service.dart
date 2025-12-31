import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard_entry.dart';
import 'leaderboard_service.dart';

class FirestoreLeaderboardService implements LeaderboardService {
  final FirebaseFirestore _db;

  FirestoreLeaderboardService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /* ───────────────── TOP USERS ───────────────── */

  @override
  Future<List<LeaderboardEntry>> getTopUsers({int limit = 10}) async {
    final snap = await _users
        .orderBy('xp', descending: true)
        .limit(limit)
        .get();

    int rank = 1;

    return snap.docs.map((doc) {
      final data = doc.data();

      return LeaderboardEntry(
        uid: doc.id,
        name:
        data['name'] ??
            data['displayName'] ??
            data['email']?.split('@').first ??
            'Student',
        profileImage: data['profileImage'] as String?,
        score: (data['xp'] as num?)?.toInt() ?? 0,
        rank: rank++,
      );
    }).toList();
  }

  /* ───────────────── USER ENTRY ───────────────── */

  @override
  Future<LeaderboardEntry?> getUserEntry(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final score = (data['xp'] as num?)?.toInt() ?? 0;

    // Rank calculation (safe for demo)
    final higherXpCount = await _users
        .where('xp', isGreaterThan: score)
        .count()
        .get();

    return LeaderboardEntry(
      uid: uid,
      name:
      data['name'] ??
          data['displayName'] ??
          data['email']?.split('@').first ??
          'Student',
      profileImage: data['profileImage'] as String?,
      score: score,
      rank: (higherXpCount.count ?? 0) + 1,    );
  }

  /* ───────────────── REFRESH (NO-OP FOR NOW) ───────────────── */

  @override
  Future<void> refreshLeaderboard() async {
    // Not needed yet (future batch aggregation)
    return;
  }
}