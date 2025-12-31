import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../features/events/models/event.dart';
import '../features/events/services/event_firestore_service.dart';
import '../core/services/auth_service.dart';

/// Developer-only screen for testing the Events backend.
/// Not part of the production UI.
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

  /// Returns the current authenticated user's uid.
  String get _uid {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.uid;
  }

  /// Creates a dummy event to simulate admin-created events.
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
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context).t('events.created')}: $id',
        ),
      ),
    );
  }

  /// Starts listening to upcoming events.
  void _listenToEvents() {
    setState(() {
      _eventsStream = _eventService.watchUpcomingEvents();
    });
  }

  /// Toggles RSVP state for the current user.
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
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('events.debugTools')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Action buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _createTestEvent,
                  child: Text(t.t('events.createTest')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _listenToEvents,
                  child: Text(t.t('events.listen')),
                ),
              ],
            ),

            const Divider(height: 32),

            // Live events stream
            if (_eventsStream != null)
              Expanded(
                child: StreamBuilder<List<Event>>(
                  stream: _eventsStream,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Text(t.t('common.loading'));
                    }

                    final events = snap.data!;
                    if (events.isEmpty) {
                      return Text(t.t('events.noEvents'));
                    }

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final e = events[index];

                        return ListTile(
                          title: Text(e.title),
                          subtitle: Text(
                            '${t.t('events.attendees')}: '
                                '${e.attendeesCount} / ${e.capacity}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _toggleRsvp(e),
                            child: Text(t.t('events.toggleRsvp')),
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