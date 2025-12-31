import '../../notifications/services/notification_service.dart';

/// Handles event-related notifications.
///
/// This service is intentionally thin:
/// - No Firestore logic
/// - No UI logic
/// - Delegates actual delivery to NotificationService
///
/// Used by:
/// - Event creation
/// - RSVP confirmation / cancellation
///
/// Note:
/// Notification failures must NEVER block core event flows.
class EventNotificationService {
  final NotificationService _notifications;

  EventNotificationService(this._notifications);

  /* ───────────────── EVENT CREATED ───────────────── */

  /// Notifies a list of users when a new event is created.
  ///
  /// `targetUids` is intentionally passed in to keep this service
  /// decoupled from user discovery logic.
  ///
  /// Example usage:
  /// - Notify followers
  /// - Notify department members
  Future<void> notifyEventCreated({
    required String eventId,
    required String title,
    required List<String> targetUids,
  }) async {
    for (final uid in targetUids) {
      await _notifications.sendSystemNotification(
        uid: uid,
        title: 'New event created',
        body: title,
      );
    }
  }

  /* ───────────────── RSVP CONFIRMED ───────────────── */

  /// Sent after a user successfully RSVPs to an event.
  /// Triggered only AFTER the RSVP transaction succeeds.
  Future<void> notifyRsvpConfirmed({
    required String eventId,
    required String uid,
    required String title,
  }) async {
    await _notifications.sendSystemNotification(
      uid: uid,
      title: 'RSVP confirmed',
      body: 'You reserved a place for "$title"',
    );
  }

  /* ───────────────── RSVP CANCELED ───────────────── */

  /// Sent after a user cancels their RSVP.
  /// Triggered only AFTER the cancellation transaction succeeds.
  Future<void> notifyRsvpCanceled({
    required String eventId,
    required String uid,
    required String title,
  }) async {
    await _notifications.sendSystemNotification(
      uid: uid,
      title: 'RSVP canceled',
      body: 'Your reservation for "$title" was canceled',
    );
  }

  /* ───────────────── EVENT FULL ───────────────── */

  /// Notifies a user when an event has reached full capacity.
  /// Can be used proactively or when a user attempts to RSVP.
  ///
  /// Currently optional and not always triggered.
  Future<void> notifyEventFull({
    required String eventId,
    required String uid,
    required String title,
  }) async {
    await _notifications.sendSystemNotification(
      uid: uid,
      title: 'Event full',
      body: '"$title" has no more available spots',
    );
  }
}