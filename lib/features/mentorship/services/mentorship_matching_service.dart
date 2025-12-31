import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mentorship_request.dart';
import '../models/mentorship_session.dart';
import '../../gamification/services/gamification_service.dart';
import '../../../core/services/firestore_user_service.dart';

class MentorshipMatchingService {
  final FirebaseFirestore _db;
  final FirestoreUserService _userService = FirestoreUserService();

  MentorshipMatchingService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('mentorship_requests');

  CollectionReference<Map<String, dynamic>> get _mentorProfiles =>
      _db.collection('mentor_profiles');

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('mentorship_sessions');

  static const String _statusPending = 'pending';
  static const String _statusAccepted = 'accepted';
  static const String _statusRejected = 'rejected';
  static const String _statusCanceled = 'canceled';
  static const String _statusCompleted = 'completed';

  // Returns: [uid] + any mentor profile doc ids owned by uid (old/random ids)
  Future<List<String>> _resolveMentorIdsForUser(String uid) async {
    final ids = <String>{uid};

    try {
      final snap = await _mentorProfiles.where('userId', isEqualTo: uid).get();
      for (final d in snap.docs) {
        ids.add(d.id);
      }
    } catch (_) {}

    return ids.toList();
  }

  Future<DocumentReference<Map<String, dynamic>>?> _resolveMentorProfileRef(
      String mentorId,
      ) async {
    final directRef = _mentorProfiles.doc(mentorId);
    final directSnap = await directRef.get();
    if (directSnap.exists) return directRef;

    final q = await _mentorProfiles.where('userId', isEqualTo: mentorId).limit(1).get();
    if (q.docs.isEmpty) return null;

    return _mentorProfiles.doc(q.docs.first.id);
  }

  Future<String> sendMentorshipRequest({
    required String studentId,
    required String mentorId,
    String? message,
  }) async {
    // normalize to actual mentor profile doc
    final mentorRef = await _resolveMentorProfileRef(mentorId);
    if (mentorRef == null) throw StateError('Mentor profile not found.');

    final mentorDocId = mentorRef.id;
    final requestRef = _requests.doc();
    final now = Timestamp.now();

    final existing = await _requests
        .where('studentId', isEqualTo: studentId)
        .where('mentorId', isEqualTo: mentorDocId)
        .where('status', whereIn: [_statusPending, _statusAccepted])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw StateError('You already have an active mentorship with this mentor.');
    }

    await _db.runTransaction((tx) async {
      final mentorSnap = await tx.get(mentorRef);
      if (!mentorSnap.exists) throw StateError('Mentor profile not found.');

      final data = mentorSnap.data() ?? {};
      final active = (data['activeMenteesCount'] ?? 0) as int;
      final max = (data['maxActiveMentees'] ?? 0) as int;

      if (max > 0 && active >= max) {
        throw StateError('Mentor is fully booked.');
      }

      tx.set(requestRef, {
        'studentId': studentId,
        'mentorId': mentorDocId,
        'message': message?.trim(),
        'status': _statusPending,
        'createdAt': now,
        'updatedAt': now,
      });
    });

    _userService.updateOnboardingFlag(studentId, 'sentMentorshipRequest', true);
    return requestRef.id;
  }

  Future<void> cancelRequest({
    required String requestId,
    required String studentId,
  }) async {
    final requestRef = _requests.doc(requestId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(requestRef);
      if (!snap.exists) throw StateError('Request not found.');

      final data = snap.data() ?? {};
      if (data['studentId'] != studentId) throw StateError('Not allowed.');

      final status = data['status'] as String?;
      final storedMentorId = (data['mentorId'] as String?) ?? '';

      if (status == _statusAccepted) {
        final mentorRef = await _resolveMentorProfileRef(storedMentorId);
        if (mentorRef != null) {
          final mentorSnap = await tx.get(mentorRef);
          final active = (mentorSnap.data()?['activeMenteesCount'] ?? 1) as int;
          tx.update(mentorRef, {
            'activeMenteesCount': active > 0 ? active - 1 : 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      tx.update(requestRef, {
        'status': _statusCanceled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> acceptRequest({
    required String requestId,
    required String mentorUid,
  }) async {
    final requestRef = _requests.doc(requestId);
    final allowedMentorIds = await _resolveMentorIdsForUser(mentorUid);

    late String studentId;
    late String storedMentorId;

    await _db.runTransaction((tx) async {
      final reqSnap = await tx.get(requestRef);
      if (!reqSnap.exists) throw StateError('Request not found.');

      final req = reqSnap.data() ?? {};
      storedMentorId = (req['mentorId'] as String?) ?? '';
      final status = req['status'] as String?;

      if (!allowedMentorIds.contains(storedMentorId)) throw StateError('Not allowed.');
      if (status != _statusPending) return;

      studentId = req['studentId'] as String;

      final mentorRef = await _resolveMentorProfileRef(storedMentorId);
      if (mentorRef == null) throw StateError('Mentor profile missing.');

      final mentorSnap = await tx.get(mentorRef);
      final data = mentorSnap.data() ?? {};
      final active = (data['activeMenteesCount'] ?? 0) as int;
      final max = (data['maxActiveMentees'] ?? 0) as int;

      if (max > 0 && active >= max) throw StateError('Mentor is fully booked.');

      tx.update(requestRef, {
        'status': _statusAccepted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.update(mentorRef, {
        'activeMenteesCount': active + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final gamification = GamificationService(firestore: _db);
    await gamification.addXp(
      uid: studentId,
      amount: 100,
      sourceType: 'mentorship_accepted',
      sourceId: requestId,
      reason: 'Mentorship accepted',
    );
  }

  Future<void> rejectRequest({
    required String requestId,
    required String mentorUid,
  }) async {
    final requestRef = _requests.doc(requestId);
    final allowedMentorIds = await _resolveMentorIdsForUser(mentorUid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(requestRef);
      if (!snap.exists) throw StateError('Request not found.');

      final data = snap.data() ?? {};
      final storedMentorId = (data['mentorId'] as String?) ?? '';
      final status = data['status'] as String?;

      if (!allowedMentorIds.contains(storedMentorId)) throw StateError('Not allowed.');
      if (status != _statusPending) return;

      tx.update(requestRef, {
        'status': _statusRejected,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> completeRequest({
    required String requestId,
    required String endedByUid,
  }) async {
    final requestRef = _requests.doc(requestId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(requestRef);
      if (!snap.exists) throw StateError('Mentorship request not found.');

      final data = snap.data() ?? {};
      final studentId = data['studentId'] as String;
      final storedMentorId = data['mentorId'] as String;

      // participant check: student or mentor user
      final mentorRef = await _resolveMentorProfileRef(storedMentorId);
      final mentorOwnerUid = mentorRef == null ? storedMentorId : (await mentorRef.get()).data()?['userId'];

      final isParticipant = endedByUid == studentId || endedByUid == mentorOwnerUid;
      if (!isParticipant) throw StateError('Unauthorized');

      if (data['status'] != _statusAccepted) throw StateError('Mentorship not active');

      tx.update(requestRef, {
        'status': _statusCompleted,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mentorRef != null) {
        tx.update(mentorRef, {
          'activeMenteesCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<List<MentorshipRequest>> streamIncomingRequestsForMentor(String uid) async* {
    final mentorIds = await _resolveMentorIdsForUser(uid);

    Query<Map<String, dynamic>> q;
    if (mentorIds.length == 1) {
      q = _requests.where('mentorId', isEqualTo: mentorIds.first);
    } else {
      q = _requests.where('mentorId', whereIn: mentorIds.take(10).toList());
    }

    yield* q
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(MentorshipRequest.fromDoc).toList());
  }

  Stream<List<MentorshipRequest>> streamMyRequestsForStudent(String studentId) {
    return _requests
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(MentorshipRequest.fromDoc).toList());
  }

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
      'notes': notes?.trim(),
      'status': sessionStatusToString(MentorshipSessionStatus.scheduled),
      'createdAt': now,
      'updatedAt': now,
    });

    return doc.id;
  }
}