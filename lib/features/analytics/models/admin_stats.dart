class AdminStats {
  // ---- User metrics ----
  // Total registered users in the system
  final int totalUsers;

  // Users active within time windows (derived from lastLogin / lastActiveAt)
  final int activeUsersLast7Days;
  final int activeUsersLast30Days;

  // ---- Mentorship metrics ----
  // Completed mentorship sessions across the platform
  final int totalMentorshipSessions;

  // Sum of mentorship session durations (in hours)
  final double totalMentorshipHours;

  // ---- Event metrics ----
  // Total number of events created
  final int totalEvents;

  // Total RSVP actions across all events
  final int totalEventRsvps;

  // ---- Resource metrics ----
  // Total resources uploaded to the system
  final int totalResources;

  // Sum of download counters across all resources
  final int totalResourceDownloads;

  // Sum of view counters across all resources
  final int totalResourceViews;

  // ---- Metadata ----
  // Timestamp of last aggregation/update
  final DateTime? lastUpdatedAt;

  const AdminStats({
    required this.totalUsers,
    required this.activeUsersLast7Days,
    required this.activeUsersLast30Days,
    required this.totalMentorshipSessions,
    required this.totalMentorshipHours,
    required this.totalEvents,
    required this.totalEventRsvps,
    required this.totalResources,
    required this.totalResourceDownloads,
    required this.totalResourceViews,
    required this.lastUpdatedAt,
  });

  /// Empty/default state used when no analytics data is available yet
  factory AdminStats.empty() {
    return const AdminStats(
      totalUsers: 0,
      activeUsersLast7Days: 0,
      activeUsersLast30Days: 0,
      totalMentorshipSessions: 0,
      totalMentorshipHours: 0.0,
      totalEvents: 0,
      totalEventRsvps: 0,
      totalResources: 0,
      totalResourceDownloads: 0,
      totalResourceViews: 0,
      lastUpdatedAt: null,
    );
  }

  /// Creates AdminStats from aggregated Firestore data
  /// Assumes all values are already computed by the service layer
  factory AdminStats.fromMap(Map<String, dynamic> map) {
    return AdminStats(
      totalUsers: map['totalUsers'] ?? 0,
      activeUsersLast7Days: map['activeUsersLast7Days'] ?? 0,
      activeUsersLast30Days: map['activeUsersLast30Days'] ?? 0,
      totalMentorshipSessions: map['totalMentorshipSessions'] ?? 0,
      totalMentorshipHours:
      (map['totalMentorshipHours'] ?? 0).toDouble(),
      totalEvents: map['totalEvents'] ?? 0,
      totalEventRsvps: map['totalEventRsvps'] ?? 0,
      totalResources: map['totalResources'] ?? 0,
      totalResourceDownloads: map['totalResourceDownloads'] ?? 0,
      totalResourceViews: map['totalResourceViews'] ?? 0,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.tryParse(map['lastUpdatedAt'])
          : null,
    );
  }

  /// Converts the analytics snapshot into a serializable map
  /// Used for caching, exports, or admin dashboards
  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'activeUsersLast7Days': activeUsersLast7Days,
      'activeUsersLast30Days': activeUsersLast30Days,
      'totalMentorshipSessions': totalMentorshipSessions,
      'totalMentorshipHours': totalMentorshipHours,
      'totalEvents': totalEvents,
      'totalEventRsvps': totalEventRsvps,
      'totalResources': totalResources,
      'totalResourceDownloads': totalResourceDownloads,
      'totalResourceViews': totalResourceViews,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }
}