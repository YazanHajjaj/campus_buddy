import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/study_group_session.dart';

class StudyGroupSessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessions(String groupId) {
    return _db
        .collection('study_groups')
        .doc(groupId)
        .collection('sessions');
  }

  // ───────────────── STREAM SESSIONS ─────────────────
  Stream<List<StudyGroupSession>> streamSessions(String groupId) {
    return _sessions(groupId)
        .orderBy('date')
        .snapshots()
        .map(
          (snap) => snap.docs
          .map((d) => StudyGroupSession.fromDoc(d, groupId))
          .toList(),
    );
  }

  // ───────────────── CREATE SESSION ─────────────────
  Future<DocumentReference<Map<String, dynamic>>> createSession({
    required String groupId,
    required String title,
    required String location,
    required Timestamp date,
    required String startTime,
    required String endTime,
    required String createdBy,
  }) async {
    return _sessions(groupId).add({
      'title': title,
      'location': location,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'createdBy': createdBy,
      'createdAt': Timestamp.now(),
    });
  }
  // ───────────────── DELETE SESSION ─────────────────
  Future<void> deleteSession({
    required String groupId,
    required String sessionId,
  }) async {
    await _sessions(groupId).doc(sessionId).delete();
  }
}