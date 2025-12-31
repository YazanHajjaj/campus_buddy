import '../models/leaderboard_entry.dart';

/// Leaderboard service backed directly by Firestore user XP.
/// Rankings are calculated at query-time.
abstract class LeaderboardService {
  /// Returns top users ordered by XP (descending).
  Future<List<LeaderboardEntry>> getTopUsers({
    int limit = 10,
  });

  /// Returns the leaderboard entry for the given user.
  Future<LeaderboardEntry?> getUserEntry(String uid);
}