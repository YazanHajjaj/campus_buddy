/// Phase 9: Leaderboard query helpers


class LeaderboardQueryHelpers {
  /// Returns top [limit] users sorted by XP.

  /// - Ensures stable ordering for consistent ranks & notifications
  static List<T> topUsersByXp<T>(
      List<T> users, {
        required int limit,
        required int Function(T u) getXp,
        String Function(T u)? getTieBreakerKey,
      }) {
    final list = List<T>.from(users);

    list.sort((a, b) {
      final xpCompare = getXp(b).compareTo(getXp(a));
      if (xpCompare != 0) return xpCompare;

      if (getTieBreakerKey != null) {
        return getTieBreakerKey!(a)
            .compareTo(getTieBreakerKey!(b));
      }
      return 0;
    });

    return list.take(limit).toList();
  }

  /// Builds a ranked list (1..N).
  ///
  /// Output is intentionally generic so it can be reused by:
  /// - UI leaderboard
  /// - Gamification badge logic
  /// - Notification rules (e.g. "You reached rank #3")
  static List<Map<String, dynamic>> buildRankedList<T>(
      List<T> users, {
        required int Function(T u) getXp,
        String Function(T u)? getName,
        String Function(T u)? getId,
      }) {
    final sorted = topUsersByXp(
      users,
      limit: users.length,
      getXp: getXp,
      getTieBreakerKey: getId,
    );

    return List.generate(sorted.length, (index) {
      final user = sorted[index];
      return {
        'rank': index + 1,
        'xp': getXp(user),
        'name': getName?.call(user),
        'id': getId?.call(user),
      };
    });
  }
}