import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/mentorship_chat_service.dart';
import 'mentorship_chat_screen.dart';

class MentorshipChatsListScreen extends StatelessWidget {
  const MentorshipChatsListScreen({super.key});

  static const _primaryBlue = Color(0xFF2446C8);

  Stream<QuerySnapshot<Map<String, dynamic>>> _streamChats(String uid) {
    return FirebaseFirestore.instance
        .collection('mentorship_chats')
        .where(
      Filter.or(
        Filter('mentorId', isEqualTo: uid),
        Filter('studentId', isEqualTo: uid),
      ),
    )
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Mentorship Chats',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _streamChats(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load chats'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No chats yet',
              subtitle: 'Your mentorship conversations will appear here',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final chatId = docs[index].id;

              final mentorId = data['mentorId'] as String;
              final studentId = data['studentId'] as String;

              final otherUserId =
              uid == mentorId ? studentId : mentorId;

              final lastText =
              (data['lastMessageText'] ?? '') as String;
              final lastAt = data['lastMessageAt'] as Timestamp?;

              return _ChatTile(
                chatId: chatId,
                otherUserId: otherUserId,
                lastMessage: lastText,
                lastMessageAt: lastAt,
              );
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── CHAT TILE ───────────────── */

class _ChatTile extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final Timestamp? lastMessageAt;

  static const _primaryBlue = Color(0xFF2446C8);

  const _ChatTile({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MentorshipChatScreen(
              chatId: chatId,
              otherUserId: otherUserId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
              _primaryBlue.withOpacity(0.12),
              child: const Icon(
                Icons.person,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage.isEmpty
                        ? 'No messages yet'
                        : lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── EMPTY STATE ───────────────── */

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}