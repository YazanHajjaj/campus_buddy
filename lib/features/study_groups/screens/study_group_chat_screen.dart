import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_localizations.dart';

class StudyGroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupTitle;

  const StudyGroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupTitle,
  });

  @override
  State<StudyGroupChatScreen> createState() =>
      _StudyGroupChatScreenState();
}

class _StudyGroupChatScreenState extends State<StudyGroupChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _messages =>
      FirebaseFirestore.instance
          .collection('study_groups')
          .doc(widget.groupId)
          .collection('messages');

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    await _messages.add({
      'senderId': _uid,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.groupTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // ───────── MESSAGE LIST ─────────
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messages
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _EmptyState(t: t);
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final isMe = data['senderId'] == _uid;

                    return _MessageBubble(
                      text: data['text'] ?? '',
                      isMe: isMe,
                      theme: theme,
                    );
                  },
                );
              },
            ),
          ),

          // ───────── INPUT BAR ─────────
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
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: t.t('studyGroups.chatHint'),
                        filled: true,
                        fillColor:
                        theme.scaffoldBackgroundColor,
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.primary,
                      child:
                      const Icon(Icons.send, color: Colors.white),
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
  final String text;
  final bool isMe;
  final ThemeData theme;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          text,
          style: TextStyle(
            color: isMe ? Colors.white : colors.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/* ───────────────── EMPTY STATE ───────────────── */

class _EmptyState extends StatelessWidget {
  final AppLocalizations t;

  const _EmptyState({required this.t});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        t.t('studyGroups.chatEmpty'),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: Colors.black54),
      ),
    );
  }
}