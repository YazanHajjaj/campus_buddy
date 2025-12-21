import 'package:cloud_firestore/cloud_firestore.dart';

/// Request lifecycle is stored as a string in Firestore
/// Enum is used in code to avoid magic strings and invalid states
enum MentorshipRequestStatus {
  pending,
  accepted,
  rejected,
  canceled,
}

/// Converts Firestore string value into enum
/// Defaults to `pending` to handle missing or legacy data safely
MentorshipRequestStatus requestStatusFromString(String? s) {
  switch (s) {
    case 'accepted':
      return MentorshipRequestStatus.accepted;
    case 'rejected':
      return MentorshipRequestStatus.rejected;
    case 'canceled':
      return MentorshipRequestStatus.canceled;
    case 'pending':
    default:
      return MentorshipRequestStatus.pending;
  }
}

/// Converts enum back to Firestore-safe string
String requestStatusToString(MentorshipRequestStatus s) {
  return s.name;
}

/// Represents a single mentorship request between a student and a mentor
/// Stored in `mentorship_requests/{requestId}`
class MentorshipRequest {
  /// Firestore document ID
  final String id;
  final String studentId;
  final String mentorId;
  final String? message;
  final MentorshipRequestStatus status;

  /// Audit timestamps
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const MentorshipRequest({
    required this.id,
    required this.studentId,
    required this.mentorId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore serialization
  /// `id` is excluded since it's the document key
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'mentorId': mentorId,
      'message': message,
      'status': requestStatusToString(status),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Safe Firestore deserialization
  /// Handles missing fields and invalid status values gracefully
  static MentorshipRequest fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return MentorshipRequest(
      id: doc.id,
      studentId: (data['studentId'] ?? '') as String,
      mentorId: (data['mentorId'] ?? '') as String,
      message: data['message'] as String?,
      status: requestStatusFromString(data['status'] as String?),
      createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      updatedAt: (data['updatedAt'] ?? Timestamp.now()) as Timestamp,
    );
  }
}
