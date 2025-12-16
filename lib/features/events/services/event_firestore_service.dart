import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import 'event_service.dart';

// Firestore implementation of EventService
// Handles all backend logic for Events (Phase 4)
// No auth logic here – uid is passed from upper layers
class EventFirestoreService implements EventService {
  final FirebaseFirestore _db;

  EventFirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ------------------ paths ------------------

  // events/{eventId}
  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');

  // events/{eventId}/rsvps/{uid}
  CollectionReference<Map<String, dynamic>> _rsvps(String eventId) =>
      _events.doc(eventId).collection('rsvps');

  // users/{uid}/rsvps/{eventId} (optional mirror)
  CollectionReference<Map<String, dynamic>> _userRsvps(String uid) =>
      _db.collection('users').doc(uid).collection('rsvps');

  // normalize date to midnight (calendar support)
  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  // ------------------ READ ------------------

  @override
  Future<List<Event>> getUpcomingEvents({int limit = 30}) async {
    final now = Timestamp.fromDate(DateTime.now());

    final snap = await _events
        .where('isActive', isEqualTo: true)
        .where('startTime', isGreaterThanOrEqualTo: now)
        .orderBy('startTime')
        .limit(limit)
        .get();

    return snap.docs
        .map((d) => Event.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Stream<List<Event>> watchUpcomingEvents({int limit = 30}) {
    final now = Timestamp.fromDate(DateTime.now());

    return _events
        .where('isActive', isEqualTo: true)
        .orderBy('startTime')
        .snapshots()
        .map(
          (snap) =>
          snap.docs.map((d) => Event.fromMap(d.id, d.data())).toList(),
    );
  }

  @override
  Future<Event?> getEventById(String eventId) async {
    final doc = await _events.doc(eventId).get();
    final data = doc.data();
    if (data == null) return null;
    return Event.fromMap(doc.id, data);
  }

  @override
  Stream<Event?> watchEventById(String eventId) {
    return _events.doc(eventId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return Event.fromMap(doc.id, data);
    });
  }

  // calendar support
  @override
  Future<List<Event>> getEventsForDate(DateTime date) async {
    final day = Timestamp.fromDate(_dayStart(date));

    final snap = await _events
        .where('isActive', isEqualTo: true)
        .where('date', isEqualTo: day)
        .orderBy('startTime')
        .get();

    return snap.docs
        .map((d) => Event.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Stream<List<Event>> watchEventsForDate(DateTime date) {
    final day = Timestamp.fromDate(_dayStart(date));

    return _events
        .where('isActive', isEqualTo: true)
        .where('date', isEqualTo: day)
        .orderBy('startTime')
        .snapshots()
        .map(
          (snap) =>
          snap.docs.map((d) => Event.fromMap(d.id, d.data())).toList(),
    );
  }

  // ------------------ RSVP ------------------

  @override
  Future<bool> hasUserRsvped({
    required String eventId,
    required String uid,
  }) async {
    final doc = await _rsvps(eventId).doc(uid).get();
    return doc.exists;
  }

  @override
  Future<bool> isEventFull(String eventId) async {
    final doc = await _events.doc(eventId).get();
    final data = doc.data();
    if (data == null) return true;

    final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
    final count = (data['attendeesCount'] as num?)?.toInt() ?? 0;

    // capacity = 0 means unlimited
    if (capacity == 0) return false;
    return count >= capacity;
  }

  @override
  Future<void> rsvpToEvent({
    required String eventId,
    required String uid,
  }) async {
    final eventRef = _events.doc(eventId);
    final rsvpRef = _rsvps(eventId).doc(uid);
    final userMirrorRef = _userRsvps(uid).doc(eventId);

    // transaction avoids race conditions
    await _db.runTransaction((tx) async {
      final eventSnap = await tx.get(eventRef);
      final eventData = eventSnap.data();

      if (eventData == null) throw StateError('Event not found');
      if (eventData['isActive'] != true) {
        throw StateError('Event inactive');
      }

      // already RSVPed
      final rsvpSnap = await tx.get(rsvpRef);
      if (rsvpSnap.exists) return;

      final capacity = (eventData['capacity'] as num?)?.toInt() ?? 0;
      final count = (eventData['attendeesCount'] as num?)?.toInt() ?? 0;

      if (capacity > 0 && count >= capacity) {
        throw StateError('Event full');
      }

      // create RSVP
      tx.set(rsvpRef, {
        'uid': uid,
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // optional user mirror
      tx.set(userMirrorRef, {
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // increment counter
      tx.update(eventRef, {
        'attendeesCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> cancelRsvp({
    required String eventId,
    required String uid,
  }) async {
    final eventRef = _events.doc(eventId);
    final rsvpRef = _rsvps(eventId).doc(uid);
    final userMirrorRef = _userRsvps(uid).doc(eventId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(rsvpRef);
      if (!snap.exists) return;

      tx.delete(rsvpRef);
      tx.delete(userMirrorRef);

      tx.update(eventRef, {
        'attendeesCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ------------------ ADMIN ------------------

  @override
  Future<String> createEvent(Event event) async {
    // NOTE:
    // - admin enforcement is handled by Firestore rules
    // - service assumes valid caller

    final doc = await _events.add({
      ...event.toMap(),

      // REQUIRED for queries
      'isActive': true,
      'attendeesCount': 0,

      // safety timestamps
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _events.doc(event.id).update({
      ...event.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setEventActive({
    required String eventId,
    required bool isActive,
  }) async {
    await _events.doc(eventId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
