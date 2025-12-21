import 'package:cloud_firestore/cloud_firestore.dart';

/// Session lifecycle states stored as strings in Firestore
/// Enum prevents invalid transitions in code
enum MentorshipSessionStatus {
  scheduled,
  completed,
  canceled,
}

/// Converts Firestore string value into enum
/// Defaults to `scheduled` for backward compatibility
MentorshipSessionStatus sessionStatusFromString(String? s) {
  switch (s) {
    case 'completed':
      return MentorshipSessionStatus.completed;
    case 'canceled':
      return MentorshipSessionStatus.canceled;
    case 'scheduled':
    default:
      return MentorshipSessionStatus.scheduled;
  }
}

/// Converts enum back to Firestore-safe string
String sessionStatusToString(MentorshipSessionStatus s) => s.name;

/// Represents a single mentorship session (meeting)
/// Stored in `mentorship_sessions/{sessionId}`
class MentorshipSession {
  /// Firestore document ID
  final String id;
  final String mentorId;
  final String studentId;
  final Timestamp scheduledAt;
  final int durationMinutes;
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

  /// Firestore serialization
  /// `id` is excluded since it's the document key
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

  /// Safe Firestore deserialization
  /// Provides defaults for optional or missing fields
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
