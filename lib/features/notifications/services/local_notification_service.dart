/// Handles notifications while the app is in the foreground.
///
/// This service is responsible for displaying local notifications
/// and routing users to the correct screen when a notification is tapped.
/// Actual plugin setup and platform code will be added later.
abstract class LocalNotificationService {
  /// Initialize local notifications.
  Future<void> initialize();

  /// Display a notification while the app is open.
  ///
  /// Payload should follow the contract defined in
  /// notification_payload_helpers.dart.
  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  });

  /// Handle user interaction with a notification.
  ///
  /// Used to route the user to the correct screen
  /// based on notification type and referenceId.
  Future<void> handleNotificationTap(
      Map<String, dynamic> payload,
      );
}