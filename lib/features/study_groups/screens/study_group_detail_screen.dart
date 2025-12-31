import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/study_group.dart';
import '../services/study_group_service.dart';
import 'study_group_sessions_screen.dart';

class StudyGroupDetailScreen extends StatelessWidget {
  final StudyGroup group;

  const StudyGroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = StudyGroupService();
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isMember = uid != null && group.memberIds.contains(uid);
    final bool isOwner = uid != null && group.ownerId == uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('studyGroups.title'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          // ───────── GROUP INFO ─────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  group.course,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Text(
                  group.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ───────── MEMBERS ─────────
          _SectionCard(
            child: Row(
              children: [
                Icon(Icons.people_outline, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  '${group.memberIds.length} ${t.t('studyGroups.members')}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ───────── SCHEDULE ─────────
          Text(
            t.t('studyGroups.schedule'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          _SectionCard(
            child: ListTile(
              leading: Icon(Icons.calendar_month, color: colors.primary),
              title: Text(
                t.t('studyGroups.viewSessions'),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudyGroupSessionsScreen(
                      groupId: group.id,
                      groupTitle: group.title,
                      ownerId: group.ownerId,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ───────── JOIN / LEAVE ─────────
          if (uid != null && !isMember)
            _PrimaryButton(
              text: t.t('studyGroups.join'),
              onPressed: () async {
                await service.joinGroup(group.id, uid);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),

          if (uid != null && isMember && !isOwner)
            _DangerButton(
              text: t.t('studyGroups.leave'),
              onPressed: () async {
                await service.leaveGroup(group.id, uid);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),

          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                t.t('studyGroups.ownerHint'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ───────────────── UI HELPERS ───────────────── */

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _DangerButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}