import '../models/event.dart';

// main API used by UI + helpers
// firestore implementation lives elsewhere
abstract class EventService {
  // ---------- READ (student) ----------

  // list of upcoming active events (simple)
  Future<List<Event>> getUpcomingEvents({
    int limit = 30,
  });

  // realtime list (events screen)
  Stream<List<Event>> watchUpcomingEvents({
    int limit = 30,
  });

  // single event fetch
  Future<Event?> getEventById(String eventId);

  // single event stream (details screen)
  Stream<Event?> watchEventById(String eventId);

  // date-based fetch (calendar screen)
  Future<List<Event>> getEventsForDate(DateTime date);

  // date-based stream (calendar screen)
  Stream<List<Event>> watchEventsForDate(DateTime date);

  // ---------- RSVP (student) ----------

  // check if uid already rsvped
  Future<bool> hasUserRsvped({
    required String eventId,
    required String uid,
  });

  // main rsvp action
  Future<void> rsvpToEvent({
    required String eventId,
    required String uid,
  });

  // cancel rsvp
  Future<void> cancelRsvp({
    required String eventId,
    required String uid,
  });

  // used by UI to disable button
  Future<bool> isEventFull(String eventId);

  // ---------- ADMIN (create/update) ----------

  // admin creates new event
  // returns new doc id
  Future<String> createEvent(Event event);

  // admin updates existing event
  Future<void> updateEvent(Event event);

  Future<void> setEventActive({
    required String eventId,
    required bool isActive,
  });
}
