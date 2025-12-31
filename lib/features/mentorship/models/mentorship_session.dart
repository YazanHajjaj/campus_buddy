import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle states for a mentorship session
/// Stored as lowercase strings in Firestore
enum MentorshipSessionStatus {
  scheduled,
  completed,
  canceled,
}

/// Converts Firestore string → enum
/// Defaults to `scheduled` for backward compatibility
MentorshipSessionStatus sessionStatusFromString(String? value) {
  switch (value) {
    case 'completed':
      return MentorshipSessionStatus.completed;
    case 'canceled':
      return MentorshipSessionStatus.canceled;
    case 'scheduled':
    default:
      return MentorshipSessionStatus.scheduled;
  }
}

/// Converts enum → Firestore-safe string
String sessionStatusToString(MentorshipSessionStatus status) {
  return status.name;
}

/// Represents a scheduled mentorship session (meeting)
/// Stored in `mentorship_sessions/{sessionId}`
class MentorshipSession {
  final String id;
  final String mentorId;
  final String studentId;

  /// Scheduled start time
  final Timestamp scheduledAt;

  /// Session duration in minutes
  final int durationMinutes;

  /// Optional private notes (mentor/admin use)
  final String? notes;

  final MentorshipSessionStatus status;

  /// Audit timestamps
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const MentorshipSession({
    required this.id,
    required this.mentorId,
    required this.studentId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts model → Firestore map
  /// Document ID is excluded (used as key)
  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'studentId': studentId,
      'scheduledAt': scheduledAt,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'status': sessionStatusToString(status),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates model from Firestore document
  /// Safely handles missing or legacy fields
  static MentorshipSession fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return MentorshipSession(
      id: doc.id,
      mentorId: (data['mentorId'] ?? '') as String,
      studentId: (data['studentId'] ?? '') as String,
      scheduledAt: (data['scheduledAt'] ?? Timestamp.now()) as Timestamp,
      durationMinutes: (data['durationMinutes'] ?? 30) as int,
      notes: data['notes'] as String?,
      status: sessionStatusFromString(data['status'] as String?),
      createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      updatedAt: (data['updatedAt'] ?? Timestamp.now()) as Timestamp,
    );
  }
}