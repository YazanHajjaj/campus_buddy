import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/study_group.dart';
import '../../../core/services/firestore_user_service.dart';

class StudyGroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('study_groups');

  // ───────────────── STREAM ALL GROUPS ─────────────────
  Stream<List<StudyGroup>> streamAllGroups() {
    return _groups
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(StudyGroup.fromDoc).toList(),
    );
  }

  // ───────────────── CREATE GROUP ─────────────────
  Future<void> createGroup({
    required String title,
    required String course,
    required String description,
    required String ownerId,
  }) async {
    final now = Timestamp.now();

    await _groups.add({
      'title': title,
      'course': course,
      'description': description,
      'ownerId': ownerId,
      'memberIds': [ownerId], // creator joins automatically
      'createdAt': now,
    });
  }

  // ───────────────── JOIN GROUP ─────────────────
  Future<void> joinGroup(String groupId, String uid) async {
    await _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });

    // Onboarding checklist: joined a study group
    _userService.updateOnboardingFlag(
      uid,
      'joinedStudyGroup',
      true,
    );
  }

  // ───────────────── LEAVE GROUP ─────────────────
  Future<void> leaveGroup(String groupId, String uid) async {
    await _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([uid]),
    });
  }

  // ====================================================
  // 🆕 STUDY GROUP SESSION SCHEDULING
  // ====================================================

  /// Schedule or update the next study session
  Future<void> scheduleSession({
    required String groupId,
    required DateTime sessionTime,
    String? location,
    String? note,
  }) async {
    await _groups.doc(groupId).update({
      'nextSessionAt': Timestamp.fromDate(sessionTime),
      if (location != null) 'sessionLocation': location,
      if (note != null) 'sessionNote': note,
    });
  }

  /// Clear scheduled session (cancel)
  Future<void> clearScheduledSession(String groupId) async {
    await _groups.doc(groupId).update({
      'nextSessionAt': FieldValue.delete(),
      'sessionLocation': FieldValue.delete(),
      'sessionNote': FieldValue.delete(),
    });
  }
}