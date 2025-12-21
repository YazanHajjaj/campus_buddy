import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

/// Handles 1-to-1 mentorship chat creation and messaging
/// This service assumes access control is enforced by Firestore rules
class MentorshipChatService {
  final FirebaseFirestore _db;

  MentorshipChatService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// mentorship_chats/{chatId}
  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('mentorship_chats');

  /// Builds a deterministic chat ID from mentor and student IDs
  /// Prevents duplicate chats for the same pair
  String buildChatId({
    required String mentorId,
    required String studentId,
  }) {
    final parts = [mentorId, studentId]..sort();
    return '${parts[0]}_${parts[1]}';
  }

  /// mentorship_chats/{chatId}/messages/{messageId}
  CollectionReference<Map<String, dynamic>> _messagesRef(String chatId) {
    return _chats.doc(chatId).collection('messages');
  }

  /// Creates the parent chat document if it does not exist
  /// Safe to call multiple times
  Future<void> ensureChatExists({
    required String chatId,
    required String mentorId,
    required String studentId,
  }) async {
    final ref = _chats.doc(chatId);
    final doc = await ref.get();
    if (doc.exists) return;

    final now = Timestamp.now();
    await ref.set({
      'mentorId': mentorId,
      'studentId': studentId,
      'createdAt': now,
      'updatedAt': now,
      'lastMessageText': null,
      'lastMessageAt': null,
    });
  }

  /// Sends a message and updates chat metadata
  /// Message write and chat update are intentionally separate
  Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final now = Timestamp.now();
    final msg = await _messagesRef(chatId).add({
      'chatId': chatId,
      'senderId': senderId,
      'text': text.trim(),
      'createdAt': now,
      'readBy': [senderId], // sender is considered read by default
    });

    await _chats.doc(chatId).set({
      'updatedAt': now,
      'lastMessageText': text.trim(),
      'lastMessageAt': now,
    }, SetOptions(merge: true));

    return msg.id;
  }

  /// Streams recent messages for a chat
  /// Messages are ordered descending for efficient pagination
  Stream<List<ChatMessage>> streamMessages(String chatId, {int limit = 50}) {
    return _messagesRef(chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  /// Marks a message as read by a specific user
  /// Uses a transaction to avoid duplicate writes
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
