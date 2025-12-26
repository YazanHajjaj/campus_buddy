/// Phase 8: Analytics helper functions
/// Pure logic only — no UI, no Firebase.

class AnalyticsHelpers {
  /// Count total items
  static int countTotal<T>(List<T> items) {
    return items.length;
  }

  /// Count items grouped by a string key
  static Map<String, int> countByKey<T>(
    List<T> items,
    String Function(T item) keySelector,
  ) {
    final Map<String, int> result = {};
    for (final item in items) {
      final key = keySelector(item);
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  /// Count items grouped by day (YYYY-MM-DD)
  static Map<String, int> countByDay<T>(
    List<T> items,
    DateTime Function(T item) dateSelector,
  ) {
    final Map<String, int> result = {};
    for (final item in items) {
      final date = dateSelector(item);
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }
}
