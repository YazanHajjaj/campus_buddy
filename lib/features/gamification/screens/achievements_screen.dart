import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import '../../analytics/services/analytics_service.dart';
import '../../analytics/models/student_analytics.dart';
import '../services/gamification_service.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';

/// Displays all achievements (badges) for the current user.
/// Progress is derived from analytics + XP.
class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final analyticsService = AnalyticsService();
    final gamificationService = GamificationService();
    final achievementService = AchievementService();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ───────── APP BAR ─────────
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('gamification.achievements'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // ───────── BODY ─────────
      body: FutureBuilder<StudentAnalytics>(
        future: analyticsService.getStudentAnalytics(uid),
        builder: (context, analyticsSnap) {
          if (analyticsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!analyticsSnap.hasData) {
            return Center(
              child: Text(t.t('gamification.noAchievements')),
            );
          }

          return StreamBuilder<int>(
            stream: gamificationService.streamXp(uid),
            builder: (context, xpSnap) {
              if (xpSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!xpSnap.hasData) {
                return Center(
                  child: Text(t.t('gamification.noAchievements')),
                );
              }

              // Build achievements from analytics + XP snapshot
              final achievements = achievementService.buildAchievements(
                analytics: analyticsSnap.data!,
                xp: xpSnap.data!,
              );

              if (achievements.isEmpty) {
                return Center(
                  child: Text(
                    t.t('gamification.noAchievements'),
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: achievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final a = achievements[index];

                  // Progress ratio (0..1)
                  final progress =
                      a.currentCount / a.requiredCount.clamp(1, a.requiredCount);

                  return _AchievementCard(
                    achievement: a,
                    progress: progress.clamp(0, 1),
                    colors: colors,
                    theme: theme,
                    t: t,
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

/* ───────────────── ACHIEVEMENT CARD ───────────────── */

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final double progress;
  final ColorScheme colors;
  final ThemeData theme;
  final AppLocalizations t;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
    required this.colors,
    required this.theme,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── HEADER ─────
          Row(
            children: [
              Icon(
                achievement.completed
                    ? Icons.emoji_events
                    : Icons.lock_outline,
                color: achievement.completed
                    ? Colors.amber
                    : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  // Title is a localization key
                  t.t(achievement.title),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ───── DESCRIPTION ─────
          Text(
            // Description is a localization key
            t.t(achievement.description),
            style: theme.textTheme.bodySmall,
          ),

          const SizedBox(height: 12),

          // ───── PROGRESS BAR ─────
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.primary.withOpacity(0.15),
            color: achievement.completed
                ? Colors.amber
                : colors.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
          ),

          const SizedBox(height: 6),

          // ───── COUNT ─────
          Text(
            '${achievement.currentCount} / ${achievement.requiredCount}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}