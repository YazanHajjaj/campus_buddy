import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import 'mentor_list_screen.dart';
import 'active_mentorships_screen.dart';

class StudentMentorshipHomeScreen extends StatelessWidget {
  const StudentMentorshipHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          t.t('mentorship.student'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _ActionTile(
            icon: Icons.search,
            title: t.t('mentorship.findMentor'),
            subtitle: t.t('mentorship.studentSubtitle'),
            destination: const MentorListScreen(),
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            title: t.t('mentorship.activeMentorships'),
            subtitle: t.t('mentorship.chat'),
            destination: const ActiveMentorshipsScreen(),
          ),
        ],
      ),
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
    final primary = theme.colorScheme.primary;

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
              backgroundColor: primary.withOpacity(0.10),
              child: Icon(
                icon,
                color: primary,
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
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}