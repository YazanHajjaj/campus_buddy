import 'package:flutter/material.dart';

class LevelUpDialog extends StatelessWidget {
  final String levelName;
  final int gainedXp;

  const LevelUpDialog({
    super.key,
    required this.levelName,
    required this.gainedXp,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Level Up!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration, size: 44, color: Colors.amber.shade700),
          const SizedBox(height: 10),
          Text("You reached: $levelName"),
          const SizedBox(height: 6),
          Text("+$gainedXp XP"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
