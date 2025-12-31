import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import 'event_service.dart';
import 'event_notification_service.dart';
import '../../analytics/services/analytics_service.dart';

class EventFirestoreService implements EventService {
  final FirebaseFirestore _db;
  final EventNotificationService? _notifications;
  final AnalyticsService _analytics;

  EventFirestoreService({
    FirebaseFirestore? firestore,
    EventNotificationService? notifications,
    AnalyticsService? analytics,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _notifications = notifications,
        _analytics = analytics ?? AnalyticsService();

  /* ───────── PATHS ───────── */

  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');

  CollectionReference<Map<String, dynamic>> _rsvps(String eventId) =>
      _events.doc(eventId).collection('rsvps');

  CollectionReference<Map<String, dynamic>> _userRsvps(String uid) =>
      _db.collection('users').doc(uid).collection('rsvps');

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  /* ───────── READ ───────── */

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
    return _events
        .where('isActive', isEqualTo: true)
        .orderBy('startTime')
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Event.fromMap(d.id, d.data())).toList(),
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
          (s) => s.docs.map((d) => Event.fromMap(d.id, d.data())).toList(),
    );
  }

  /* ───────── RSVP ───────── */

  @override
  Future<bool> hasUserRsvped({
    required String eventId,
    required String uid,
  }) async {
    return (await _rsvps(eventId).doc(uid).get()).exists;
  }

  @override
  Future<bool> isEventFull(String eventId) async {
    final doc = await _events.doc(eventId).get();
    final data = doc.data();
    if (data == null) return true;

    final capacity = (data['capacity'] as num?)?.toInt() ?? 0;
    final count = (data['attendeesCount'] as num?)?.toInt() ?? 0;

    return capacity > 0 && count >= capacity;
  }

  @override
  Future<void> rsvpToEvent({
    required String eventId,
    required String uid,
  }) async {
    final eventRef = _events.doc(eventId);
    late Event event;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(eventRef);
      final data = snap.data();
      if (data == null) throw StateError('Event not found');

      event = Event.fromMap(snap.id, data);

      final rsvpRef = _rsvps(eventId).doc(uid);
      if ((await tx.get(rsvpRef)).exists) return;

      if (event.capacity > 0 &&
          event.attendeesCount >= event.capacity) {
        throw StateError('Event full');
      }

      tx.set(rsvpRef, {
        'uid': uid,
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(_userRsvps(uid).doc(eventId), {
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(eventRef, {
        'attendeesCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // 🔔 Notification
    await _notifications?.notifyRsvpConfirmed(
      eventId: eventId,
      uid: uid,
      title: event.title,
    );

    // 📊 Analytics (NON-BLOCKING)
    await _analytics.logEventRsvp(
      uid: uid,
      eventId: eventId,
    );
  }

  @override
  Future<void> cancelRsvp({
    required String eventId,
    required String uid,
  }) async {
    final eventSnap = await _events.doc(eventId).get();
    if (!eventSnap.exists) return;

    final event = Event.fromMap(eventSnap.id, eventSnap.data()!);

    await _db.runTransaction((tx) async {
      final rsvpRef = _rsvps(eventId).doc(uid);
      if (!(await tx.get(rsvpRef)).exists) return;

      tx.delete(rsvpRef);
      tx.delete(_userRsvps(uid).doc(eventId));

      tx.update(_events.doc(eventId), {
        'attendeesCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _notifications?.notifyRsvpCanceled(
      eventId: eventId,
      uid: uid,
      title: event.title,
    );
  }

  /* ───────── ADMIN ───────── */

  @override
  Future<String> createEvent(Event event) async {
    final doc = await _events.add({
      ...event.toMap(),
      'isActive': true,
      'attendeesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notifications?.notifyEventCreated(
      eventId: doc.id,
      title: event.title,
      targetUids: const [],
    );

    return doc.id;
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _events.doc(event.id).update({
      ...event.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEventImage({
    required String eventId,
    required String imageUrl,
  }) async {
    await _events.doc(eventId).update({
      'imageUrl': imageUrl,
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