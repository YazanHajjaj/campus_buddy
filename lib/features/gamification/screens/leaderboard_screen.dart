import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import '../models/leaderboard_entry.dart';
import '../services/firestore_leaderboard_service.dart';
import '../services/gamification_service.dart';

import 'badges_screen.dart';
import 'reward_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);

    final leaderboardService = FirestoreLeaderboardService();
    final gamificationService = GamificationService();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ───────── APP BAR ─────────
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('gamification.leaderboard'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: t.t('gamification.rewards'),
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RewardScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // ───────── BODY ─────────
      body: Column(
        children: [
          // 🔧 DEV XP BUTTON (TOP)
          if (uid != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bug_report),
                  label: const Text(
                    'DEV: +100 XP',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final now = DateTime.now().millisecondsSinceEpoch.toString();

                    await gamificationService.addXp(
                      uid: uid,
                      amount: 100,
                      sourceType: 'dev_test',
                      sourceId: now,
                      reason: 'Dev XP button',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ +100 XP added')),
                    );
                  },
                ),
              ),
            ),

          // ───────── LEADERBOARD LIST ─────────
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: leaderboardService.getTopUsers(limit: 20),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      t.t('gamification.noLeaderboardData'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final entries = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: entries.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // ───────── HEADER ─────────
                    if (index == 0) {
                      return _LeaderboardHeader();
                    }

                    final entry = entries[index - 1];
                    final rank = entry.rank;

                    IconData? rankIcon;
                    if (rank == 1) rankIcon = Icons.emoji_events;
                    if (rank == 2) rankIcon = Icons.emoji_events_outlined;
                    if (rank == 3) rankIcon = Icons.workspace_premium;

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          colors.primary.withOpacity(0.12),
                          backgroundImage: entry.profileImage != null
                              ? NetworkImage(entry.profileImage!)
                              : null,
                          child: entry.profileImage == null
                              ? Text(
                            rank.toString(),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                              : null,
                        ),
                        title: Text(
                          entry.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${entry.score} XP',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: rankIcon == null
                            ? null
                            : Icon(rankIcon, color: Colors.amber),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── HEADER ───────────────── */

class _LeaderboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('gamification.topStudents'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            t.t('gamification.leaderboardDescription'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 14),

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
    );
  }
}