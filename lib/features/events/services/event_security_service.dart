// Event security definition
// This file documents access rules and intent.
// Real enforcement is handled by Firestore security rules,
// not by client-side Dart code.

class EventSecurityService {
  // ================= ROLES =================
  //
  // Admin:
  // - create events
  // - update events
  // - activate / deactivate events
  // - upload event banner images
  //
  // Student:
  // - read active events
  // - RSVP to events
  // - cancel own RSVP
  //
  // Guests / unauthenticated:
  // - no access

  // ================= RULES =================
  //
  // Create / Update / Delete:
  // - admin only
  // - checked by Firestore rules
  //
  // Read:
  // - all authenticated users
  // - only events where isActive == true
  //
  // RSVP:
  // - event must be active
  // - user can RSVP only once
  // - blocked if capacity reached
  //
  // Cancel RSVP:
  // - only if user already RSVPed
  //
  // ================= NOTES =================
  //
  // - No FirebaseAuth calls here
  // - Role checks are assumed to be done upstream
  // - This file exists as documentation + future hook
}
