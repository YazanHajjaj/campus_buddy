import 'package:cloud_firestore/cloud_firestore.dart';
import '../../analytics/services/analytics_service.dart';

class MentorshipSessionService {
  final _db = FirebaseFirestore.instance;

  Future<void> completeSession({
    required String sessionId,
    required String studentId,
    required String mentorId,
  }) async {
    final ref = _db.collection('mentorship_sessions').doc(sessionId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (!snap.exists) {
        // 🔹 CREATE session first
        tx.set(ref, {
          'studentId': studentId,
          'mentorId': mentorId,
          'status': 'completed',
          'durationMinutes': 60, // demo-safe default
          'createdAt': FieldValue.serverTimestamp(),
          'completedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 🔹 UPDATE existing session
        tx.update(ref, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}