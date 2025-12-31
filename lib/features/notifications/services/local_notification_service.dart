/// Handles local notifications and reminders.
///
/// This service is responsible for:
/// - Showing in-app (foreground) notifications
/// - Scheduling local reminders (offline-capable)
/// - Routing users when a notification is tapped
///
/// Platform-specific implementations (Android / iOS)
/// will be added later using flutter_local_notifications
/// or similar plugins.
abstract class LocalNotificationService {
  // ───────────────── INITIALIZATION ─────────────────

  /// Initialize local notifications.
  ///
  /// Should be called once at app startup.
  Future<void> initialize();

  // ───────────────── FOREGROUND NOTIFICATIONS ─────────────────

  /// Display a notification while the app is open.
  ///
  /// Payload must follow the contract defined in:
  /// helpers/notification_payload_helpers.dart
  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  });

  // ───────────────── LOCAL REMINDERS ─────────────────

  /// Schedule a local reminder.
  ///
  /// - [id] must be unique (used for canceling later)
  /// - [scheduledAt] is the exact time the reminder should fire
  /// - [payload] is used for navigation when tapped
  ///
  /// This must work fully offline.
  Future<void> scheduleReminder({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  });

  /// Cancel a scheduled reminder.
  Future<void> cancelReminder(int id);

  /// Cancel all scheduled reminders.
  Future<void> cancelAllReminders();

  // ───────────────── INTERACTION HANDLING ─────────────────

  /// Handle user interaction with a notification or reminder.
  ///
  /// Used to route the user to the correct screen
  /// based on notification type and referenceId.
  Future<void> handleNotificationTap(
      Map<String, dynamic> payload,
      );

}