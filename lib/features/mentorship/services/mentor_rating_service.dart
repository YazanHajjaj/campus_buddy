import 'package:cloud_firestore/cloud_firestore.dart';

class MentorRatingService {
  final FirebaseFirestore _db;

  MentorRatingService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<DocumentReference<Map<String, dynamic>>> _resolveMentorProfileRef(
      String mentorId,
      ) async {
    // 1️⃣ Try direct doc ID
    final directRef = _db.collection('mentor_profiles').doc(mentorId);
    final directSnap = await directRef.get();
    if (directSnap.exists) return directRef;

    // 2️⃣ Fallback: match by userId
    final q = await _db
        .collection('mentor_profiles')
        .where('userId', isEqualTo: mentorId)
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      throw StateError('Mentor profile not found');
    }

    return q.docs.first.reference;
  }

  Future<void> submitRating({
    required String mentorId,
    required String studentId,
    required int rating,
    String? comment,
  }) async {
    assert(rating >= 1 && rating <= 5);

    final mentorRef = await _resolveMentorProfileRef(mentorId);
    final ratingRef =
    mentorRef.collection('ratings').doc(studentId);

    await _db.runTransaction((tx) async {
      final mentorSnap = await tx.get(mentorRef);

      final data = mentorSnap.data()!;
      final currentAvg = (data['ratingAvg'] ?? 0).toDouble();
      final currentCount = (data['ratingCount'] ?? 0) as int;

      final existing = await tx.get(ratingRef);
      if (existing.exists) {
        throw StateError('Already rated');
      }

      final newCount = currentCount + 1;
      final newAvg =
          ((currentAvg * currentCount) + rating) / newCount;

      tx.set(ratingRef, {
        'studentId': studentId,
        'rating': rating,
        'comment': comment?.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(mentorRef, {
        'ratingAvg': newAvg,
        'ratingCount': newCount,
      });
    });
  }
}