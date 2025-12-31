import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle states for a mentorship request
enum MentorshipRequestStatus {
  pending,
  accepted,
  rejected,
  canceled,
}

/// Converts Firestore string → enum
MentorshipRequestStatus requestStatusFromString(String? value) {
  switch (value) {
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

/// Converts enum → Firestore string
String requestStatusToString(MentorshipRequestStatus status) {
  return status.name;
}

/// Represents a document in:
/// mentorship_requests/{requestId}
class MentorshipRequest {
  final String id;
  final String studentId;
  final String mentorId;
  final String? message;
  final MentorshipRequestStatus status;
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

  /// Used only if needed later (not required now)
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

  /// Safe Firestore → Model parser
  static MentorshipRequest fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw StateError('MentorshipRequest document ${doc.id} has no data');
    }

    return MentorshipRequest(
      id: doc.id,
      studentId: (data['studentId'] as String?) ?? '',
      mentorId: (data['mentorId'] as String?) ?? '',
      message: data['message'] as String?,
      status: requestStatusFromString(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
      updatedAt: (data['updatedAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}