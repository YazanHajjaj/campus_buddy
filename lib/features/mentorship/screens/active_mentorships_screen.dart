import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';
import 'package:campus_buddy/core/utils/firebase_error_debug.dart';

import '../models/mentorship_request.dart';
import '../models/mentor_profile.dart';
import '../services/mentorship_matching_service.dart';
import '../services/mentorship_chat_service.dart';
import '../services/mentorship_session_service.dart';

import 'mentorship_chat_screen.dart';
import 'mentor_rating_screen.dart';

class ActiveMentorshipsScreen extends StatelessWidget {
  const ActiveMentorshipsScreen({super.key});

  /* ───────────────── STREAM ───────────────── */

  Stream<List<MentorshipRequest>> _streamAcceptedRequests(String uid) {
    return FirebaseFirestore.instance
        .collection('mentorship_requests')
        .where('status', isEqualTo: 'accepted')
        .where(
      Filter.or(
        Filter('studentId', isEqualTo: uid),
        Filter('mentorId', isEqualTo: uid),
      ),
    )
        .snapshots()
        .map(
          (snap) => snap.docs
          .map(MentorshipRequest.fromDoc)
          .where(
            (r) => r.studentId.isNotEmpty && r.mentorId.isNotEmpty,
      )
          .toList(),
    );
  }

  Future<MentorProfile?> _loadMentor(String mentorProfileId) async {
    final snap = await FirebaseFirestore.instance
        .collection('mentor_profiles')
        .doc(mentorProfileId)
        .get();

    if (!snap.exists || snap.data() == null) return null;
    return MentorProfile.fromDoc(snap);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = MentorshipMatchingService();

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(t.t('error.unauthorized'))),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('mentorship.active'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<List<MentorshipRequest>>(
        stream: _streamAcceptedRequests(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(debugFirebaseError(snapshot.error!)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: t.t('mentorship.noActive'),
              subtitle: t.t('mentorship.noActiveHint'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _ActiveMentorshipCard(
                request: items[index],
                loadMentor: _loadMentor,
                service: service,
                currentUid: uid,
              );
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── CARD ───────────────── */

class _ActiveMentorshipCard extends StatelessWidget {
  final MentorshipRequest request;
  final Future<MentorProfile?> Function(String) loadMentor;
  final MentorshipMatchingService service;
  final String currentUid;

  const _ActiveMentorshipCard({
    required this.request,
    required this.loadMentor,
    required this.service,
    required this.currentUid,
  });

  /* ───────── END MENTORSHIP ───────── */

  Future<void> _endMentorship(BuildContext context) async {
    final t = AppLocalizations.of(context);

    try {
      await MentorshipSessionService().completeSession(
        sessionId: request.id,
        studentId: request.studentId,
        mentorId: request.mentorId,
      );

      await service.cancelRequest(
        requestId: request.id,
        studentId: request.studentId,
      );

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorRatingScreen(
            mentorId: request.mentorId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      showDebugSnackBar(context, 'End mentorship failed', e);
    }
  }

  /* ───────── OPEN CHAT ───────── */

  Future<void> _openChat(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final chatService = MentorshipChatService();

    try {
      // mentorId here = mentor_profiles doc id
      final mentorProfileSnap = await FirebaseFirestore.instance
          .collection('mentor_profiles')
          .doc(request.mentorId)
          .get();

      final mentorUid =
          (mentorProfileSnap.data()?['userId'] as String?) ?? '';

      if (mentorUid.isEmpty) {
        throw StateError(
          'mentor_profiles/${request.mentorId} missing userId',
        );
      }

      final chatId = chatService.buildChatId(
        mentorUid: mentorUid,
        studentUid: request.studentId,
      );

      await chatService.ensureChatExists(
        chatId: chatId,
        mentorUid: mentorUid,
        studentUid: request.studentId,
        mentorProfileId: request.mentorId,
      );

      if (!context.mounted) return;

      final otherUid =
      currentUid == request.studentId ? mentorUid : request.studentId;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorshipChatScreen(
            chatId: chatId,
            otherUserId: otherUid,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      showDebugSnackBar(context, 'Open chat failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final isStudent = currentUid == request.studentId;

    return FutureBuilder<MentorProfile?>(
      future: loadMentor(request.mentorId),
      builder: (context, snapshot) {
        final mentor = snapshot.data;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.12),
                    child: Icon(
                      Icons.school,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isStudent
                              ? (mentor?.name ?? t.t('mentorship.mentor'))
                              : t.t('mentorship.student'),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mentor?.department ?? '—',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => _openChat(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _endMentorship(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: Text(
                    t.t('mentorship.end'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}