import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message inside a mentorship or study group chat
/// Stored under `mentorship_chats/{chatId}/messages/{messageId}`
/// or `study_groups/{groupId}/messages/{messageId}`
class ChatMessage {
  /// Firestore document ID
  final String id;

  /// Parent chat identifier
  /// Used to keep message documents self-contained
  final String chatId;

  /// users/{uid} of the sender
  final String senderId;
  final String text;
  final Timestamp createdAt;
  final List<String> readBy;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.readBy,
  });

  /// Firestore serialization
  /// `id` is excluded since it's the document key
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt,
      'readBy': readBy,
    };
  }

  /// Safe Firestore deserialization
  /// Ensures missing read receipts do not break the UI
  static ChatMessage fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      chatId: (data['chatId'] ?? '') as String,
      senderId: (data['senderId'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      readBy: List<String>.from((data['readBy'] ?? const []) as List),
    );
  }
}
