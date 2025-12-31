import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

/// Handles 1-to-1 mentorship chat creation and messaging
/// Access control is enforced by Firestore rules
class MentorshipChatService {
  final FirebaseFirestore _db;

  MentorshipChatService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('mentorship_chats');

  String buildChatId({
    required String mentorUid,
    required String studentUid,
  }) {
    final parts = [mentorUid, studentUid]..sort();
    return '${parts[0]}_${parts[1]}';
  }

  CollectionReference<Map<String, dynamic>> _messagesRef(String chatId) {
    return _chats.doc(chatId).collection('messages');
  }

  Future<void> ensureChatExists({
    required String chatId,
    required String mentorUid,
    required String studentUid,
    String? mentorProfileId,
  }) async {
    final ref = _chats.doc(chatId);
    final doc = await ref.get();
    if (doc.exists) return;

    final now = Timestamp.now();

    await ref.set({
      // ✅ NEW (rules use these)
      'mentorUid': mentorUid,
      'studentUid': studentUid,

      // optional (nice to keep)
      'mentorProfileId': mentorProfileId,

      'createdAt': now,
      'updatedAt': now,
      'lastMessageText': null,
      'lastMessageAt': null,

      // ✅ BACKWARD COMPAT (old fields)
      'mentorId': mentorUid,
      'studentId': studentUid,
    });
  }

  Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return '';

    final now = Timestamp.now();

    final msg = await _messagesRef(chatId).add({
      'chatId': chatId,
      'senderId': senderId,
      'text': clean,
      'createdAt': now,
      'readBy': [senderId],
    });

    await _chats.doc(chatId).set({
      'updatedAt': now,
      'lastMessageText': clean,
      'lastMessageAt': now,
    }, SetOptions(merge: true));

    return msg.id;
  }

  Stream<List<ChatMessage>> streamMessages(String chatId, {int limit = 50}) {
    return _messagesRef(chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
    required String uid,
  }) async {
    final ref = _messagesRef(chatId).doc(messageId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final readBy = List<String>.from((data['readBy'] ?? const []) as List);

      if (readBy.contains(uid)) return;

      readBy.add(uid);
      tx.update(ref, {'readBy': readBy});
    });
  }
}