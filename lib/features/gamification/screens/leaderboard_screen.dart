import 'package:flutter/material.dart';
import 'reward_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _Entry(name: "Ayla", xp: 1240),
      _Entry(name: "Omar", xp: 1120),
      _Entry(name: "Mina", xp: 980),
      _Entry(name: "Yazan", xp: 910),
      _Entry(name: "Shahd", xp: 860),
      _Entry(name: "Ahmed", xp: 820),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        actions: [
          IconButton(
            tooltip: "Rewards",
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Top Students (Dummy)",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                      "This is placeholder data. Real ranking comes later after Yazan + Mahmoud.",
                    ),
                  ],
                ),
              ),
            );
          }

          final entry = entries[index - 1];
          final rank = index;

          IconData? icon;
          if (rank == 1) icon = Icons.emoji_events;
          if (rank == 2) icon = Icons.emoji_events_outlined;
          if (rank == 3) icon = Icons.workspace_premium;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(rank.toString()),
              ),
              title: Text(entry.name),
              subtitle: Text("${entry.xp} XP"),
              trailing: icon == null ? null : Icon(icon),
            ),
          );
        },
      ),
    );
  }
}

class _Entry {
  final String name;
  final int xp;
  const _Entry({required this.name, required this.xp});
}
