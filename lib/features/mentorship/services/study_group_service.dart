import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/study_group.dart';

/// Handles study group lifecycle, membership, and group chat
/// Access control is enforced via Firestore rules
class StudyGroupService {
  final FirebaseFirestore _db;

  StudyGroupService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// study_groups/{groupId}
  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('study_groups');

  /// study_groups/{groupId}/members/{uid}
  CollectionReference<Map<String, dynamic>> _membersRef(String groupId) {
    return _groups.doc(groupId).collection('members');
  }

  /// study_groups/{groupId}/messages/{messageId}
  CollectionReference<Map<String, dynamic>> _messagesRef(String groupId) {
    return _groups.doc(groupId).collection('messages');
  }

  // ---- groups ----

  /// Streams groups for discovery
  /// Privacy filtering is handled at the rule level
  Stream<List<StudyGroup>> streamGroups({int limit = 50}) {
    return _groups
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(StudyGroup.fromDoc).toList());
  }

  /// Creates a new study group and adds the creator as owner
  /// Member count is initialized eagerly to avoid subcollection reads
  Future<String> createGroup({
    required String title,
    String? description,
    required String createdBy,
    List<String> tags = const [],
    int maxMembers = 10,
    bool isPrivate = false,
  }) async {
    final now = Timestamp.now();

    final doc = await _groups.add({
      'title': title.trim(),
      'description': description,
      'createdBy': createdBy,
      'tags': tags,
      'memberCount': 1,
      'maxMembers': maxMembers,
      'isPrivate': isPrivate,
      'createdAt': now,
      'updatedAt': now,
    });

    // Creator is automatically added as group owner
    await _membersRef(doc.id).doc(createdBy).set({
      'uid': createdBy,
      'joinedAt': now,
      'role': 'owner',
    });

    return doc.id;
  }

  /// Adds a user to a group
  /// Uses a transaction to enforce capacity limits safely
  Future<void> joinGroup({
    required String groupId,
    required String uid,
  }) async {
    final groupRef = _groups.doc(groupId);
    final memberRef = _membersRef(groupId).doc(uid);

    await _db.runTransaction((tx) async {
      final gSnap = await tx.get(groupRef);
      if (!gSnap.exists) throw StateError('Group not found.');

      final data = gSnap.data() as Map<String, dynamic>;
      final memberCount = (data['memberCount'] ?? 0) as int;
      final maxMembers = (data['maxMembers'] ?? 10) as int;

      // Prevent duplicate joins
      final mSnap = await tx.get(memberRef);
      if (mSnap.exists) return;

      if (memberCount >= maxMembers) {
        throw StateError('Group is full.');
      }

      final now = Timestamp.now();

      tx.set(memberRef, {
        'uid': uid,
        'joinedAt': now,
        'role': 'member',
      });

      tx.update(groupRef, {
        'memberCount': memberCount + 1,
        'updatedAt': now,
      });
    });
  }

  /// Removes a user from a group
  /// Member count is decremented atomically
  Future<void> leaveGroup({
    required String groupId,
    required String uid,
  }) async {
    final groupRef = _groups.doc(groupId);
    final memberRef = _membersRef(groupId).doc(uid);

    await _db.runTransaction((tx) async {
      final gSnap = await tx.get(groupRef);
      if (!gSnap.exists) return;

      final mSnap = await tx.get(memberRef);
      if (!mSnap.exists) return;

      final data = gSnap.data() as Map<String, dynamic>;
      final memberCount = (data['memberCount'] ?? 0) as int;

      tx.delete(memberRef);

      final now = Timestamp.now();
      tx.update(groupRef, {
        'memberCount': memberCount > 0 ? memberCount - 1 : 0,
        'updatedAt': now,
      });
    });
  }

  /// Streams member IDs for presence and permission checks
  Stream<List<String>> streamMemberIds(String groupId) {
    return _membersRef(groupId).snapshots().map((snap) {
      return snap.docs.map((d) => d.id).toList();
    });
  }

  // ---- group messages ----

  /// Sends a message inside a study group chat
  /// Message format is shared with mentorship chat for consistency
  Future<String> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String text,
  }) async {
    final now = Timestamp.now();
    final doc = await _messagesRef(groupId).add({
      'chatId': groupId,
      'senderId': senderId,
      'text': text.trim(),
      'createdAt': now,
      'readBy': [senderId],
    });

    await _groups.doc(groupId).set({
      'updatedAt': now,
      'lastMessageText': text.trim(),
      'lastMessageAt': now,
    }, SetOptions(merge: true));

    return doc.id;
  }

  /// Streams recent messages for a group chat
  Stream<List<ChatMessage>> streamGroupMessages(
      String groupId, {
        int limit = 50,
      }) {
    return _messagesRef(groupId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }
}
