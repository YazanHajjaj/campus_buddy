import 'package:flutter/material.dart';
import 'level_up_dialog.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = const [
      _Reward(title: "Bronze Level", subtitle: "Unlocked at 500 XP"),
      _Reward(title: "Silver Level", subtitle: "Unlocked at 1000 XP"),
      _Reward(title: "Gold Level", subtitle: "Unlocked at 2000 XP"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Rewards")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rewards (Dummy)",
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    "Later this will be tied to XP levels and badge unlocks.",
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: const Text("Show Level Up Dialog (test)"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const LevelUpDialog(
                          levelName: "Silver",
                          gainedXp: 120,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...rewards.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.card_giftcard),
                  title: Text(r.title),
                  subtitle: Text(r.subtitle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reward {
  final String title;
  final String subtitle;
  const _Reward({required this.title, required this.subtitle});
}
