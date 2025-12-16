// Event calendar definition
// Explains how events are mapped to calendar views
// and how date-based logic works.

class EventCalendarService {
  // ================= EVENT DATES =================
  //
  // - Each event stores a `date` field (midnight timestamp)
  // - `startTime` and `endTime` define the exact time range
  //
  // Example:
  // date       = 2025-12-20 00:00
  // startTime = 2025-12-20 14:00
  // endTime   = 2025-12-20 16:00

  // ================= CALENDAR VIEW =================
  //
  // - calendar screen highlights days that have events
  // - clicking a day fetches events where:
  //   event.date == selected date
  //
  // ================= FUTURE EXTENSIONS =================
  //
  // - export event to device calendar
  // - sync with Google / Apple calendar
  //
  // ================= NOTES =================
  //
  // - calendar UI is handled by the Events Calendar screen
  // - this service defines logic & meaning only
}
