import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import 'mentor_incoming_requests_screen.dart';
import 'active_mentorships_screen.dart';
import 'create_mentor_profile_screen.dart';
import 'edit_mentor_profile_screen.dart';

class MentorMentorshipHomeScreen extends StatelessWidget {
  const MentorMentorshipHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ✅ SAME APPBAR BEHAVIOR AS MentorListScreen
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('mentorship.mentor'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: uid == null
          ? Center(child: Text(t.t('error.unauthorized')))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('mentor_profiles')
            .where('userId', isEqualTo: uid)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // ❌ NO PROFILE → CREATE
          if (docs.isEmpty) {
            return const _CreateMentorPrompt();
          }

          // ✅ PROFILE EXISTS → DASHBOARD
          return const _MentorDashboard();
        },
      ),
    );
  }
}

/* ───────────────── CREATE PROMPT ───────────────── */

class _CreateMentorPrompt extends StatelessWidget {
  const _CreateMentorPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.person_outline,
                size: 42,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.t('mentorship.becomeMentor'),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.t('mentorship.becomeMentorHint'),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMentorProfileScreen(),
                    ),
                  );
                },
                child: Text(
                  t.t('mentorship.createProfile'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── DASHBOARD ───────────────── */

class _MentorDashboard extends StatelessWidget {
  const _MentorDashboard();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ActionTile(
          icon: Icons.inbox_outlined,
          title: t.t('mentorship.incoming'),
          subtitle: t.t('mentorship.incomingHint'),
          destination: const MentorIncomingRequestsScreen(),
        ),
        const SizedBox(height: 14),
        _ActionTile(
          icon: Icons.chat_bubble_outline,
          title: t.t('mentorship.activeMentorships'),
          subtitle: t.t('mentorship.activeMentorshipsHint'),
          destination: const ActiveMentorshipsScreen(),
        ),
        const SizedBox(height: 14),
        _ActionTile(
          icon: Icons.edit_outlined,
          title: t.t('profile.edit'),
          subtitle: t.t('mentorship.editProfileHint'),
          destination: const EditMentorProfileScreen(),
        ),
      ],
    );
  }
}

/* ───────────────── ACTION TILE ───────────────── */

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Icon(
                icon,
                color: colors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}