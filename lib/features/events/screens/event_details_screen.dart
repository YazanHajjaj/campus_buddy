import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_firestore_service.dart';

// shows one event
// minimal UI, full logic
class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _eventService = EventFirestoreService();

  // TEMP: replace with auth uid later
  final String _dummyUid = 'test-user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: StreamBuilder<Event?>(
        stream: _eventService.watchEventById(widget.eventId),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error / missing
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found'));
          }

          final event = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 8),

                // date & location
                Text('${event.location} • ${event.startTime}'),

                const SizedBox(height: 16),

                // description
                Text(event.description),

                const Spacer(),

                // rsvp button
                FutureBuilder<bool>(
                  future: _eventService.hasUserRsvped(
                    eventId: event.id,
                    uid: _dummyUid,
                  ),
                  builder: (context, rsvpSnap) {
                    final hasRsvped = rsvpSnap.data == true;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (hasRsvped) {
                            await _eventService.cancelRsvp(
                              eventId: event.id,
                              uid: _dummyUid,
                            );
                          } else {
                            await _eventService.rsvpToEvent(
                              eventId: event.id,
                              uid: _dummyUid,
                            );
                          }
                        },
                        child: Text(
                          hasRsvped ? 'Cancel RSVP' : 'RSVP',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
