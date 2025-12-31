import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import '../models/chat_message.dart';
import '../services/mentorship_chat_service.dart';

class MentorshipChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const MentorshipChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<MentorshipChatScreen> createState() =>
      _MentorshipChatScreenState();
}

class _MentorshipChatScreenState extends State<MentorshipChatScreen> {
  /// 🔴 DEMO FLAG — keep true for presentation
  static const bool _demoMode = true;

  final _service = MentorshipChatService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    await _service.sendMessage(
      chatId: widget.chatId,
      senderId: _uid,
      text: text,
    );
  }

  /// Load other user profile ONCE
  Future<DocumentSnapshot<Map<String, dynamic>>> _loadOtherUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /* ───────── CHAT HEADER ───────── */
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _loadOtherUser(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            final name = data?['name'] as String?;
            final photoUrl = data?['photoUrl'] as String?;

            return Row(
              children: [
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                  colors.primary.withValues(alpha: 0.12),
                  backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Icon(Icons.person, color: colors.primary)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name ?? t.t('mentorship.chat'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: Column(
        children: [
          /* ───────── MESSAGES ───────── */
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _service.streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return _EmptyState(
                    text: t.t('mentorship.noMessages'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];

                    /// 🔥 DEMO LOGIC
                    final bool isMe = _demoMode
                        ? index.isEven
                        : m.senderId == _uid;

                    return _MessageBubble(
                      message: m,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          /* ───────── INPUT BAR ───────── */
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: t.t('mentorship.typeMessage'),
                        filled: true,
                        fillColor:
                        theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _send,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.primary,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── MESSAGE BUBBLE ───────────────── */

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? colors.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/* ───────────────── EMPTY STATE ───────────────── */

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.black54),
      ),
    );
  }
}