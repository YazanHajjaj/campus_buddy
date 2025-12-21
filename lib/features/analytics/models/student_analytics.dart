import 'usage_metrics.dart';

class StudentAnalytics {
  final String userId;

  // Aggregated usage metrics
  final UsageMetrics usageMetrics;

  // Mentorship
  final int mentorshipSessionsCount;
  final double mentorshipHoursTotal;
  final DateTime? mentorshipLastSessionAt;

  // Events
  final int eventsRsvpCount;
  final DateTime? eventsLastRsvpAt;

  // Resources
  final int resourcesUploadedCount;

  // Metadata
  final DateTime? lastUpdatedAt;

  const StudentAnalytics({
    required this.userId,
    required this.usageMetrics,
    required this.mentorshipSessionsCount,
    required this.mentorshipHoursTotal,
    required this.mentorshipLastSessionAt,
    required this.eventsRsvpCount,
    required this.eventsLastRsvpAt,
    required this.resourcesUploadedCount,
    required this.lastUpdatedAt,
  });

  factory StudentAnalytics.empty(String userId) {
    return StudentAnalytics(
      userId: userId,
      usageMetrics: UsageMetrics.empty(),
      mentorshipSessionsCount: 0,
      mentorshipHoursTotal: 0.0,
      mentorshipLastSessionAt: null,
      eventsRsvpCount: 0,
      eventsLastRsvpAt: null,
      resourcesUploadedCount: 0,
      lastUpdatedAt: null,
    );
  }

  factory StudentAnalytics.fromMap(
      String userId,
      Map<String, dynamic> map,
      ) {
    return StudentAnalytics(
      userId: userId,
      usageMetrics: map['usageMetrics'] != null
          ? UsageMetrics.fromMap(
        Map<String, dynamic>.from(map['usageMetrics']),
      )
          : UsageMetrics.empty(),
      mentorshipSessionsCount: map['mentorshipSessionsCount'] ?? 0,
      mentorshipHoursTotal:
      (map['mentorshipHoursTotal'] ?? 0).toDouble(),
      mentorshipLastSessionAt:
      map['mentorshipLastSessionAt'] != null
          ? DateTime.tryParse(map['mentorshipLastSessionAt'])
          : null,
      eventsRsvpCount: map['eventsRsvpCount'] ?? 0,
      eventsLastRsvpAt: map['eventsLastRsvpAt'] != null
          ? DateTime.tryParse(map['eventsLastRsvpAt'])
          : null,
      resourcesUploadedCount: map['resourcesUploadedCount'] ?? 0,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.tryParse(map['lastUpdatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usageMetrics': usageMetrics.toMap(),
      'mentorshipSessionsCount': mentorshipSessionsCount,
      'mentorshipHoursTotal': mentorshipHoursTotal,
      'mentorshipLastSessionAt':
      mentorshipLastSessionAt?.toIso8601String(),
      'eventsRsvpCount': eventsRsvpCount,
      'eventsLastRsvpAt': eventsLastRsvpAt?.toIso8601String(),
      'resourcesUploadedCount': resourcesUploadedCount,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }
}