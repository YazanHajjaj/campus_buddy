import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mentor_profile.dart';

/// Handles all reads and writes related to mentor profiles
/// This service owns the `mentor_profiles` collection
class MentorService {
  final FirebaseFirestore _db;

  MentorService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// mentor_profiles/{mentorId}
  CollectionReference<Map<String, dynamic>> get _mentorProfiles =>
      _db.collection('mentor_profiles');

  // ---------- read ----------

  /// Streams active mentors ordered by rating
  /// Used for mentor discovery and browsing
  Stream<List<MentorProfile>> streamMentors({int limit = 50}) {
    return _mentorProfiles
        .where('isActive', isEqualTo: true)
        .orderBy('ratingAvg', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MentorProfile.fromDoc).toList());
  }

  /// Same as `streamMentors` but scoped to a department
  /// This query is index-backed and used by matching logic
  Stream<List<MentorProfile>> streamMentorsByDepartment(
      String department, {
        int limit = 50,
      }) {
    return _mentorProfiles
        .where('isActive', isEqualTo: true)
        .where('department', isEqualTo: department)
        .orderBy('ratingAvg', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MentorProfile.fromDoc).toList());
  }

  /// One-time fetch used when opening mentor details
  Future<MentorProfile?> getMentorProfile(String mentorId) async {
    final doc = await _mentorProfiles.doc(mentorId).get();
    if (!doc.exists) return null;
    return MentorProfile.fromDoc(doc);
  }

  /// Live profile stream used by mentor self-edit screens
  Stream<MentorProfile?> streamMentorProfile(String mentorId) {
    return _mentorProfiles.doc(mentorId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MentorProfile.fromDoc(doc);
    });
  }

  // ---------- write ----------

  /// Creates or updates a mentor profile
  /// Preserves counters and rating fields to avoid accidental resets
  Future<void> upsertMentorProfile({
    required String mentorId,
    required String userId,
    required String name,
    String? photoUrl,
    String? bio,
    String? department,
    String? faculty,
    List<String> expertise = const [],
    bool isActive = true,
  }) async {
    final now = Timestamp.now();
    final ref = _mentorProfiles.doc(mentorId);

    // Preserve original creation time if the document already exists
    final existing = await ref.get();
    final createdAt = existing.exists
        ? (existing.data()?['createdAt'] as Timestamp? ?? now)
        : now;

    await ref.set({
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'department': department,
      'faculty': faculty,
      'expertise': expertise,
      'isActive': isActive,

      // These fields are managed elsewhere (ratings / matching)
      'ratingAvg': existing.data()?['ratingAvg'] ?? 0.0,
      'ratingCount': existing.data()?['ratingCount'] ?? 0,
      'activeMenteesCount': existing.data()?['activeMenteesCount'] ?? 0,

      'createdAt': createdAt,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  /// Soft-enable / disable mentor visibility
  /// Used instead of deleting to keep historical data intact
  Future<void> setMentorActive(String mentorId, bool active) async {
    await _mentorProfiles.doc(mentorId).update({
      'isActive': active,
      'updatedAt': Timestamp.now(),
    });
  }
}
