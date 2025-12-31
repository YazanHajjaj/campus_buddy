import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import 'level_up_dialog.dart';
import 'badges_screen.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    final rewards = const [
      _Reward(title: 'Bronze', subtitle: 'Unlocked at 500 XP'),
      _Reward(title: 'Silver', subtitle: 'Unlocked at 1000 XP'),
      _Reward(title: 'Gold', subtitle: 'Unlocked at 2000 XP'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ───────── APP BAR ─────────
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('gamification.rewards'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ───────── HEADER CARD ─────────
          _CardShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('gamification.rewardsTitle'),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  t.t('gamification.rewardsDescription'),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.black54),
                ),

                const SizedBox(height: 16),

                // ───── LEVEL UP TEST ─────
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: Text(
                      t.t('gamification.showLevelUp'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const LevelUpDialog(
                          levelName: 'Silver',
                          gainedXp: 120,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ───── VIEW BADGES ─────
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: Text(
                      t.t('gamification.viewBadges'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BadgesScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ───────── REWARD LIST ─────────
          ...rewards.map(
                (r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.primary.withOpacity(0.12),
                  child: Icon(
                    Icons.card_giftcard,
                    color: colors.primary,
                  ),
                ),
                title: Text(
                  r.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(r.subtitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── CARD SHELL ───────────────── */

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/* ───────────────── DATA ───────────────── */

class _Reward {
  final String title;
  final String subtitle;
  const _Reward({required this.title, required this.subtitle});
}