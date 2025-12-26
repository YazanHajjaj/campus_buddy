/// Phase 8: Analytics chart helpers
/// Transforms aggregated stats into chart-friendly structures.
/// No Firebase, no UI logic.

class AnalyticsChartHelpers {
  /// Sorts date-based stats (YYYY-MM-DD) chronologically
  static Map<String, int> sortByDate(
      Map<String, int> data,
      ) {
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(entries);
  }

  /// Extracts labels for charts (keys)
  static List<String> buildLabels(
      Map<String, int> data,
      ) {
    return data.keys.toList();
  }

  /// Extracts values for charts
  static List<int> buildValues(
      Map<String, int> data,
      ) {
    return data.values.toList();
  }

  /// Builds a chart-ready structure
  static Map<String, List<dynamic>> buildChartData(
      Map<String, int> data,
      ) {
    final sorted = sortByDate(data);

    return {
      'labels': buildLabels(sorted),
      'values': buildValues(sorted),
    };
  }
}