/// Phase 4: Event query helpers
/// Keep this file PURE (no Firebase calls, no UI).
class EventQueryHelpers {
  /// Sort events by date/time (newest first by default)
  static List<T> sortByDate<T>(
    List<T> events, {
    bool newestFirst = true,
    DateTime Function(T e)? getDate,
  }) {
    if (getDate == null) return events;

    final copy = List<T>.from(events);
    copy.sort((a, b) {
      final da = getDate(a);
      final db = getDate(b);
      return newestFirst ? db.compareTo(da) : da.compareTo(db);
    });
    return copy;
  }

  /// Filter events that happen on the same calendar day as [day]
  static List<T> filterByDay<T>(
    List<T> events,
    DateTime day, {
    DateTime Function(T e)? getDate,
  }) {
    if (getDate == null) return events;

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return events.where((e) => sameDay(getDate(e), day)).toList();
  }

  /// Filter events by category/tag (depends on model fields)
  static List<T> filterByCategory<T>(
    List<T> events,
    String category, {
    String Function(T e)? getCategory,
  }) {
    if (getCategory == null) return events;

    final target = category.trim().toLowerCase();
    return events
        .where((e) => getCategory(e).trim().toLowerCase() == target)
        .toList();
  }
}
