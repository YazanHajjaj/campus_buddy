import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/localization/app_localizations.dart';
import '../models/study_group.dart';
import '../services/study_group_service.dart';
import 'create_study_group_screen.dart';
import 'study_group_detail_screen.dart';

class StudyGroupsListScreen extends StatelessWidget {
  const StudyGroupsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = StudyGroupService();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

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
          t.t('studyGroups.title'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateStudyGroupScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<StudyGroup>>(
        stream: service.streamAllGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return _EmptyState(t: t);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final isMember = group.memberIds.contains(uid);

              return _StudyGroupCard(
                group: group,
                isMember: isMember,
                t: t,
                theme: theme,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudyGroupDetailScreen(group: group),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── GROUP CARD ───────────────── */

class _StudyGroupCard extends StatelessWidget {
  final StudyGroup group;
  final bool isMember;
  final VoidCallback onTap;
  final AppLocalizations t;
  final ThemeData theme;

  const _StudyGroupCard({
    required this.group,
    required this.isMember,
    required this.onTap,
    required this.t,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Icon(Icons.group, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.course,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${group.memberIds.length} ${t.t('studyGroups.members')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isMember
                          ? colors.primary
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              t.t('studyGroups.emptyTitle'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              t.t('studyGroups.emptySubtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}