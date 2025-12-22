import '../models/leaderboard_entry.dart';

/// Interface for leaderboard access.
/// Aggregation and ranking logic are handled in later phases.
abstract class LeaderboardService {
  /// Returns the top users ordered by score.
  /// Limit is typically small (e.g. top 10).
  Future<List<LeaderboardEntry>> getTopUsers({
    int limit = 10,
  });

  /// Returns the leaderboard entry for a specific user, if available.
  Future<LeaderboardEntry?> getUserEntry(String uid);

  /// Triggers a leaderboard refresh.
  /// Intended for scheduled / batch updates (not realtime).
  Future<void> refreshLeaderboard();
}