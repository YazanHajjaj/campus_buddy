class UsageMetrics {
  // Resource activity
  final int resourceViews;
  final int resourceDownloads;

  // Mentorship activity
  final int mentorshipMessagesSent;
  final int mentorshipSessionsCompleted;

  // Events activity
  final int eventsAttended;

  // Study groups
  final int studyGroupsJoined;

  // Activity tracking
  final DateTime? lastActiveAt;
  final int totalActiveDays;

  const UsageMetrics({
    required this.resourceViews,
    required this.resourceDownloads,
    required this.mentorshipMessagesSent,
    required this.mentorshipSessionsCompleted,
    required this.eventsAttended,
    required this.studyGroupsJoined,
    required this.lastActiveAt,
    required this.totalActiveDays,
  });

  factory UsageMetrics.empty() {
    return const UsageMetrics(
      resourceViews: 0,
      resourceDownloads: 0,
      mentorshipMessagesSent: 0,
      mentorshipSessionsCompleted: 0,
      eventsAttended: 0,
      studyGroupsJoined: 0,
      lastActiveAt: null,
      totalActiveDays: 0,
    );
  }

  factory UsageMetrics.fromMap(Map<String, dynamic> map) {
    return UsageMetrics(
      resourceViews: map['resourceViews'] ?? 0,
      resourceDownloads: map['resourceDownloads'] ?? 0,
      mentorshipMessagesSent: map['mentorshipMessagesSent'] ?? 0,
      mentorshipSessionsCompleted:
      map['mentorshipSessionsCompleted'] ?? 0,
      eventsAttended: map['eventsAttended'] ?? 0,
      studyGroupsJoined: map['studyGroupsJoined'] ?? 0,
      lastActiveAt: map['lastActiveAt'] != null
          ? DateTime.tryParse(map['lastActiveAt'])
          : null,
      totalActiveDays: map['totalActiveDays'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resourceViews': resourceViews,
      'resourceDownloads': resourceDownloads,
      'mentorshipMessagesSent': mentorshipMessagesSent,
      'mentorshipSessionsCompleted': mentorshipSessionsCompleted,
      'eventsAttended': eventsAttended,
      'studyGroupsJoined': studyGroupsJoined,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'totalActiveDays': totalActiveDays,
    };
  }
}