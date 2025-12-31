import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';
import '../models/mentorship_request.dart';
import '../services/mentorship_matching_service.dart';

class MentorIncomingRequestsScreen extends StatelessWidget {
  const MentorIncomingRequestsScreen({super.key});

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
          t.t('mentorship.incoming'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<List<MentorshipRequest>>(
        stream: service.streamIncomingRequestsForMentor(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(t.t('common.error')));
          }

          final requests = (snapshot.data ?? [])
              .where((r) => r.status == MentorshipRequestStatus.pending)
              .toList();

          if (requests.isEmpty) {
            return _EmptyState(
              icon: Icons.inbox_outlined,
              title: t.t('mentorship.noRequests'),
              subtitle: t.t('mentorship.noRequestsHint'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _RequestCard(
                request: requests[index],
                service: service,
                mentorUid: uid,
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final MentorshipRequest request;
  final MentorshipMatchingService service;
  final String mentorUid;

  const _RequestCard({
    required this.request,
    required this.service,
    required this.mentorUid,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _loading = false;

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadStudent() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.request.studentId)
        .get();
  }

  Future<void> _accept(AppLocalizations t) async {
    setState(() => _loading = true);
    try {
      await widget.service.acceptRequest(
        requestId: widget.request.id,
        mentorUid: widget.mentorUid,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject(AppLocalizations t) async {
    setState(() => _loading = true);
    try {
      await widget.service.rejectRequest(
        requestId: widget.request.id,
        mentorUid: widget.mentorUid,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('common.error'))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _loadStudent(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final photoUrl = data?['photoUrl'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
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
                    radius: 22,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Icon(Icons.person, color: colors.primary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.t('mentorship.student'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const _StatusBadge(),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => _reject(t),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(color: colors.error),
                      ),
                      child: Text(t.t('common.reject')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _accept(t),
                      child: _loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(t.t('common.accept')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Pending',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

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
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}