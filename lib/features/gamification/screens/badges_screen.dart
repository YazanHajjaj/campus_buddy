import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import '../services/gamification_service.dart';

/// Displays all earned badges for the current user.
/// Badge definitions are static; earned state comes from gamification service.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final gamificationService = GamificationService();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ───────── APP BAR ─────────
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('gamification.myBadges'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // ───────── BODY ─────────
      body: StreamBuilder<List<String>>(
        stream: gamificationService.streamEarnedBadges(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final earnedBadgeIds = snapshot.data!;

          if (earnedBadgeIds.isEmpty) {
            return _EmptyState();
          }

          final badges = earnedBadgeIds
              .map(_BadgeCatalog.fromId)
              .whereType<_BadgeView>()
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.9,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              return _BadgeCard(
                badge: badges[index],
                t: t,
              );
            },
          );
        },
      ),
    );
  }
}

/* ───────────────── BADGE CARD ───────────────── */

class _BadgeCard extends StatelessWidget {
  final _BadgeView badge;
  final AppLocalizations t;

  const _BadgeCard({
    required this.badge,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: badge.color.withOpacity(0.15),
            child: Icon(
              badge.icon,
              size: 32,
              color: badge.color,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            // Title is a localization key
            t.t(badge.titleKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            // Description is a localization key
            t.t(badge.descriptionKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colors.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── EMPTY STATE ───────────────── */

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 12),
            Text(
              t.t('gamification.noBadges'),
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              t.t('gamification.noBadgesHint'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── BADGE CATALOG ───────────────── */
/* Maps Firestore badge IDs → UI metadata (NO logic) */

class _BadgeView {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  const _BadgeView({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });
}

class _BadgeCatalog {
  static _BadgeView? fromId(String id) {
    switch (id) {
      case 'badge_bronze':
        return const _BadgeView(
          titleKey: 'gamification.badge.bronze.title',
          descriptionKey: 'gamification.badge.bronze.desc',
          icon: Icons.emoji_events,
          color: Colors.brown,
        );
      case 'badge_silver':
        return const _BadgeView(
          titleKey: 'gamification.badge.silver.title',
          descriptionKey: 'gamification.badge.silver.desc',
          icon: Icons.emoji_events,
          color: Colors.grey,
        );
      case 'badge_gold':
        return const _BadgeView(
          titleKey: 'gamification.badge.gold.title',
          descriptionKey: 'gamification.badge.gold.desc',
          icon: Icons.workspace_premium,
          color: Colors.amber,
        );
      default:
        return null;
    }
  }
}