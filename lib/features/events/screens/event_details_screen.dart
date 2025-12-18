import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data (UI only)
    const title = "Robotics Club Meetup";
    const description =
        "Join us for a discussion about upcoming competitions and tasks.";
    const location = "Engineering Building - Room 305";
    const date = "Dec 20, 2025";
    const time = "18:00 - 20:00";
    const capacity = 40;
    const attending = 17;
    const tags = ["Robotics", "Workshop", "Campus"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          Text(description),
          const SizedBox(height: 16),

          _InfoRow(icon: Icons.place, label: "Location", value: location),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.calendar_today, label: "Date", value: date),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.schedule, label: "Time", value: time),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            children: tags.map((t) => Chip(label: Text(t))).toList(),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Capacity"),
                  const SizedBox(height: 8),
                  Text("$attending / $capacity attending"),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: attending / capacity),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("RSVP clicked (UI only)"),
                ),
              );
            },
            child: const Text("RSVP"),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
