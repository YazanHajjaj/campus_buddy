import 'package:flutter/material.dart';

import '../features/events/models/event.dart';
import '../features/events/services/event_firestore_service.dart';
import '../core/services/auth_service.dart';

// Developer-only screen to test Events backend
// NOT part of real UI
class DeveloperToolsEventsTest extends StatefulWidget {
  const DeveloperToolsEventsTest({super.key});

  @override
  State<DeveloperToolsEventsTest> createState() =>
      _DeveloperToolsEventsTestState();
}

class _DeveloperToolsEventsTestState extends State<DeveloperToolsEventsTest> {
  final EventFirestoreService _eventService = EventFirestoreService();
  final AuthService _authService = AuthService();

  Stream<List<Event>>? _eventsStream;

  // quick access to auth uid
  String get _uid {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.uid;
  }

  // create dummy event (admin simulation)
  Future<void> _createTestEvent() async {
    final now = DateTime.now();

    final event = Event(
      id: '',
      title: 'Test Event ${now.second}',
      description: 'Developer test event',
      location: 'Campus Hall',
      date: DateTime(now.year, now.month, now.day),
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
      createdBy: _uid,
      isOnline: false,
      imageUrl: null,
      tags: ['test', 'debug'],
      capacity: 2,
      attendeesCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _eventService.createEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event created: $id')),
    );
  }

  // listen to upcoming events
  void _listenToEvents() {
    setState(() {
      _eventsStream = _eventService.watchUpcomingEvents();
    });
  }

  // rsvp test
  Future<void> _toggleRsvp(Event event) async {
    final hasRsvped =
    await _eventService.hasUserRsvped(eventId: event.id, uid: _uid);

    if (hasRsvped) {
      await _eventService.cancelRsvp(eventId: event.id, uid: _uid);
    } else {
      await _eventService.rsvpToEvent(eventId: event.id, uid: _uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events Debug Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // actions
            Row(
              children: [
                ElevatedButton(
                  onPressed: _createTestEvent,
                  child: const Text('Create Test Event'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _listenToEvents,
                  child: const Text('Listen Events'),
                ),
              ],
            ),

            const Divider(height: 32),

            // live events stream
            if (_eventsStream != null)
              Expanded(
                child: StreamBuilder<List<Event>>(
                  stream: _eventsStream,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Text('Waiting for events...');
                    }

                    final events = snap.data!;
                    if (events.isEmpty) {
                      return const Text('No events found');
                    }

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final e = events[index];

                        return ListTile(
                          title: Text(e.title),
                          subtitle: Text(
                            'Count: ${e.attendeesCount} / ${e.capacity}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _toggleRsvp(e),
                            child: const Text('Toggle RSVP'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
