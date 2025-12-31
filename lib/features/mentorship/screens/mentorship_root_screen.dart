import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import 'student_mentorship_home_screen.dart';
import 'mentor_mentorship_home_screen.dart';

/// Entry point for the mentorship feature.
/// Lets the user choose whether to continue as a student or a mentor.
class MentorshipRootScreen extends StatelessWidget {
  const MentorshipRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // Main mentorship entry app bar
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          t.t('mentorship.title'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.t('mentorship.continueAs'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 32),

            // ───────── STUDENT ROLE ─────────
            _RoleCard(
              icon: Icons.school_outlined,
              title: t.t('mentorship.student'),
              subtitle: t.t('mentorship.studentSubtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentMentorshipHomeScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ───────── MENTOR ROLE ─────────
            _RoleCard(
              icon: Icons.person_outline,
              title: t.t('mentorship.mentor'),
              subtitle: t.t('mentorship.mentorSubtitle'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MentorMentorshipHomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── ROLE CARD ───────────────── */

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
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
              backgroundColor:
              theme.colorScheme.primary.withOpacity(0.10),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}