// Phase 4 — Event Details screen
// UI renders event information
// Event backend logic already exists and is accessed via services
// Static data is used here only to keep UI decoupled from services


import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    // TEMP STATIC DATA
// Used only for UI layout and testing
// Real data is provided by Event services when wired


    const title = "Robotics Club Meetup";
    const description =
        "Join us for a discussion about upcoming competitions and tasks.";
    const location = "Engineering Building - Room 305";
    const date = "Dec 20, 2025";
    const time = "18:00 - 20:00";
    const capacity = 40;
    const attending = 17;
    const tags = ["Robotics", "Workshop", "Campus"];

    // Prevent division by zero in progress bar
    final progress =
    capacity > 0 ? attending / capacity : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event banner placeholder (UI only)
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

          // Event title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Event description
          Text(description),
          const SizedBox(height: 16),

          // Event metadata
          const _InfoRow(
            icon: Icons.place,
            label: "Location",
            value: location,
          ),
          const SizedBox(height: 8),
          const _InfoRow(
            icon: Icons.calendar_today,
            label: "Date",
            value: date,
          ),
          const SizedBox(height: 8),
          const _InfoRow(
            icon: Icons.schedule,
            label: "Time",
            value: time,
          ),

          const SizedBox(height: 16),

          // Event tags
          Wrap(
            spacing: 8,
            children: tags.map((t) => Chip(label: Text(t))).toList(),
          ),

          const SizedBox(height: 16),

          // Capacity card (UI only)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Capacity",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text("$attending / $capacity attending"),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // RSVP button (UI only)
          FilledButton(
            onPressed: () {
              // TEMP ACTION
              // Later: connect to RSVP backend logic
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

// Simple reusable row for displaying labeled event info
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
