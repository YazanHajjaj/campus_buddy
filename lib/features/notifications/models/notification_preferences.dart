import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores notification preferences for a single user.
/// This model only represents data structure.
/// No sending logic should live here.
class NotificationPreferences {
  final String uid;

  final bool eventsEnabled;
  final bool mentorshipEnabled;
  final bool studyGroupsEnabled;
  final bool gamificationEnabled;
  final bool adminAnnouncementsEnabled;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  const NotificationPreferences({
    required this.uid,
    required this.eventsEnabled,
    required this.mentorshipEnabled,
    required this.studyGroupsEnabled,
    required this.gamificationEnabled,
    required this.adminAnnouncementsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Default preferences for a new user.
  /// Kept permissive to avoid missing important notifications.
  factory NotificationPreferences.defaults(String uid) {
    final now = Timestamp.now();
    return NotificationPreferences(
      uid: uid,
      eventsEnabled: true,
      mentorshipEnabled: true,
      studyGroupsEnabled: true,
      gamificationEnabled: true,
      adminAnnouncementsEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory NotificationPreferences.fromMap(
      Map<String, dynamic> data,
      String uid,
      ) {
    return NotificationPreferences(
      uid: uid,
      eventsEnabled: data['eventsEnabled'] ?? true,
      mentorshipEnabled: data['mentorshipEnabled'] ?? true,
      studyGroupsEnabled: data['studyGroupsEnabled'] ?? true,
      gamificationEnabled: data['gamificationEnabled'] ?? true,
      adminAnnouncementsEnabled:
      data['adminAnnouncementsEnabled'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'eventsEnabled': eventsEnabled,
      'mentorshipEnabled': mentorshipEnabled,
      'studyGroupsEnabled': studyGroupsEnabled,
      'gamificationEnabled': gamificationEnabled,
      'adminAnnouncementsEnabled': adminAnnouncementsEnabled,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  NotificationPreferences copyWith({
    bool? eventsEnabled,
    bool? mentorshipEnabled,
    bool? studyGroupsEnabled,
    bool? gamificationEnabled,
    bool? adminAnnouncementsEnabled,
    Timestamp? updatedAt,
  }) {
    return NotificationPreferences(
      uid: uid,
      eventsEnabled: eventsEnabled ?? this.eventsEnabled,
      mentorshipEnabled: mentorshipEnabled ?? this.mentorshipEnabled,
      studyGroupsEnabled:
      studyGroupsEnabled ?? this.studyGroupsEnabled,
      gamificationEnabled:
      gamificationEnabled ?? this.gamificationEnabled,
      adminAnnouncementsEnabled:
      adminAnnouncementsEnabled ?? this.adminAnnouncementsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? Timestamp.now(),
    );
  }
}