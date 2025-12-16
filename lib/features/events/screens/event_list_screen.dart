import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_firestore_service.dart';
import 'event_details_screen.dart';

// basic events list
// UI will be replaced later
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  // service instance
  final _eventService = EventFirestoreService();

  // cached stream (IMPORTANT)
  late final Stream<List<Event>> _eventsStream;

  @override
  void initState() {
    super.initState();

    // create stream ONCE
    _eventsStream = _eventService.watchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: StreamBuilder<List<Event>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          // loading state (first connection only)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error state
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load events'));
          }

          final events = snapshot.data ?? [];

          // empty state (real empty, not flicker)
          if (events.isEmpty) {
            return const Center(child: Text('No upcoming events'));
          }

          // simple list view
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return ListTile(
                title: Text(event.title),
                subtitle: Text(
                  '${event.location} • ${event.startTime}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EventDetailsScreen(eventId: event.id),
                    ),
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
