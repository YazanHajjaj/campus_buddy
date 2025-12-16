// Event notification definition
// Describes when notifications should be triggered.
// Actual sending is handled by backend services (FCM / Cloud Functions).

class EventNotificationService {
  // ================= TRIGGERS =================
  //
  // 1. RSVP confirmation
  // - sent immediately after user RSVPs
  //
  // 2. Event reminder
  // - 24 hours before event start
  // - 1 hour before event start
  //
  // 3. Event update (optional)
  // - when admin updates time/location
  //
  // 4. Capacity reached (optional)
  // - notify admin when event becomes full

  // ================= DELIVERY =================
  //
  // - push notifications via Firebase Cloud Messaging (FCM)
  // - scheduled using Cloud Functions / Cloud Scheduler
  //
  // ================= NOTES =================
  //
  // - client app does NOT schedule notifications
  // - this avoids reliability issues when app is closed
  // - Flutter side only reacts to received notifications
}
