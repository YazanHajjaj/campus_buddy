import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mentorship_request.dart';
import '../models/mentorship_session.dart';

/// Owns mentorship request lifecycle, session creation,
/// and mentor matching logic.
/// This service enforces cross-document consistency.
class MentorshipMatchingService {
  final FirebaseFirestore _db;

  MentorshipMatchingService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// mentorship_requests/{requestId}
  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('mentorship_requests');

  /// mentorship_sessions/{sessionId}
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('mentorship_sessions');

  /// mentor_profiles/{mentorId}
  CollectionReference<Map<String, dynamic>> get _mentorProfiles =>
      _db.collection('mentor_profiles');

  // ----- helpers -----

  /// Ensures a student can only have one active pending request
  /// This constraint is enforced at service level and backed by rules
  Future<bool> _studentHasActiveRequest(String studentId) async {
    final snap = await _requests
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  // ----- requests -----

  /// Creates a new mentorship request
  /// Throws if the student already has a pending request
  Future<String> sendMentorshipRequest({
    required String studentId,
    required String mentorId,
    String? message,
  }) async {
    if (await _studentHasActiveRequest(studentId)) {
      throw StateError('Student already has an active request.');
    }

    final now = Timestamp.now();
    final doc = await _requests.add({
      'studentId': studentId,
      'mentorId': mentorId,
      'message': message,
      'status': requestStatusToString(MentorshipRequestStatus.pending),
      'createdAt': now,
      'updatedAt': now,
    });

    return doc.id;
  }

  /// Allows a student to cancel their own pending request
  /// Uses a transaction to prevent race conditions with mentor actions
  Future<void> cancelRequest({
    required String requestId,
    required String studentId,
  }) async {
    final ref = _requests.doc(requestId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('Request not found.');

      final data = snap.data() as Map<String, dynamic>;
      if ((data['studentId'] ?? '') != studentId) {
        throw StateError('Not allowed.');
      }

      final status = (data['status'] ?? 'pending') as String;
      if (status != 'pending') return;

      tx.update(ref, {
        'status': requestStatusToString(MentorshipRequestStatus.canceled),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Accepts a mentorship request and updates mentor load counters
  /// Both operations are atomic to keep matching data consistent
  Future<void> acceptRequest({
    required String requestId,
    required String mentorId,
  }) async {
    final reqRef = _requests.doc(requestId);
    final mentorProfileRef = _mentorProfiles.doc(mentorId);

    await _db.runTransaction((tx) async {
      final reqSnap = await tx.get(reqRef);
      if (!reqSnap.exists) {
        throw StateError('Request not found.');
      }

      final reqData = reqSnap.data() as Map<String, dynamic>;
      if ((reqData['mentorId'] ?? '') != mentorId) {
        throw StateError('Not allowed.');
      }

      final status = (reqData['status'] ?? 'pending') as String;
      if (status != 'pending') return;

      final mentorSnap = await tx.get(mentorProfileRef);
      final currentMentees =
      mentorSnap.exists
          ? (mentorSnap.data()?['activeMenteesCount'] ?? 0) as int
          : 0;

      final now = Timestamp.now();

      tx.update(reqRef, {
        'status': requestStatusToString(MentorshipRequestStatus.accepted),
        'updatedAt': now,
      });

      if (mentorSnap.exists) {
        tx.update(mentorProfileRef, {
          'activeMenteesCount': currentMentees + 1,
          'updatedAt': now,
        });
      }
    });
  }

  /// Rejects a mentorship request
  /// Does not modify mentor counters
  Future<void> rejectRequest({
    required String requestId,
    required String mentorId,
  }) async {
    final ref = _requests.doc(requestId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('Request not found.');

      final data = snap.data() as Map<String, dynamic>;
      if ((data['mentorId'] ?? '') != mentorId) {
        throw StateError('Not allowed.');
      }

      final status = (data['status'] ?? 'pending') as String;
      if (status != 'pending') return;

      tx.update(ref, {
        'status': requestStatusToString(MentorshipRequestStatus.rejected),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Streams incoming requests for a mentor dashboard
  Stream<List<MentorshipRequest>> streamIncomingRequestsForMentor(
      String mentorId, {
        int limit = 50,
      }) {
    return _requests
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MentorshipRequest.fromDoc).toList());
  }

  /// Streams all requests created by a student
  Stream<List<MentorshipRequest>> streamMyRequestsForStudent(
      String studentId, {
        int limit = 50,
      }) {
    return _requests
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MentorshipRequest.fromDoc).toList());
  }

  // ----- sessions -----

  /// Creates a scheduled mentorship session
  /// Called only after a request is accepted
  Future<String> createSession({
    required String mentorId,
    required String studentId,
    required DateTime scheduledAt,
    int durationMinutes = 30,
    String? notes,
  }) async {
    final now = Timestamp.now();
    final doc = await _sessions.add({
      'mentorId': mentorId,
      'studentId': studentId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'status': sessionStatusToString(MentorshipSessionStatus.scheduled),
      'createdAt': now,
      'updatedAt': now,
    });

    return doc.id;
  }

  /// Streams sessions for a student
  /// Mentor sessions are queried separately to avoid OR queries
  Stream<List<MentorshipSession>> streamSessionsForUser(
      String uid, {
        int limit = 50,
      }) {
    return _sessions
        .where('studentId', isEqualTo: uid)
        .orderBy('scheduledAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MentorshipSession.fromDoc).toList());
  }

  /// Streams sessions for a mentor
  Stream<List<MentorshipSession>> streamSessionsForMentor(
      String mentorId, {
        int limit = 50,
      }) {
    return _sessions
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('scheduledAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MentorshipSession.fromDoc).toList());
  }

  // ----- matching -----

  /// Returns a ranked list of mentor IDs for a student
  /// Scoring favors high rating and lower active mentee count
  Future<List<String>> recommendMentorsForStudent({
    required String studentDepartment,
    int limit = 10,
  }) async {
    final snap = await _mentorProfiles
        .where('isActive', isEqualTo: true)
        .where('department', isEqualTo: studentDepartment)
        .limit(50)
        .get();

    final scored = snap.docs.map((doc) {
      final d = doc.data();
      final rating = _asDouble(d['ratingAvg']);
      final mentees = (d['activeMenteesCount'] ?? 0) as int;

      // Higher score = higher priority
      final score = (rating * 10.0) - (mentees * 1.5);
      return MapEntry(doc.id, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(limit).map((e) => e.key).toList();
  }

  /// Normalizes Firestore numeric values
  double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return 0.0;
  }
}
