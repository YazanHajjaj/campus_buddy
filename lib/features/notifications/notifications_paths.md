# Notifications — Firestore Paths & Responsibilities

This document defines where notification-related data lives
and which parts of the system are responsible for reading or writing it.

This phase focuses on structure and ownership, not enforcement.

---

## 1. Notification Preferences

### Path
notification_preferences/{uid}

### Purpose
Stores per-user notification toggles.
Used by backend logic and Cloud Functions to decide
whether a notification should be sent.

### Fields
- uid
- eventsEnabled
- mentorshipEnabled
- studyGroupsEnabled
- gamificationEnabled
- adminAnnouncementsEnabled
- createdAt
- updatedAt

### Ownership
- Created when a user first enables notifications
- Updated by the user via the notification settings screen
- Read by notification-sending logic

---

## 2. FCM Tokens

### Path
users/{uid}/fcmTokens/{tokenId}

### Purpose
Stores all active FCM tokens for a user.
Supports multiple devices per account.

### Fields
- token
- platform (optional)
- appVersion (optional)
- createdAt
- lastSeenAt

### Ownership
- Written by the app on login / app start
- Updated when Firebase refreshes a token
- Cleaned up when tokens become invalid

---

## 3. Notification Triggers (Logical Mapping)

Notifications are triggered by events in other modules.
Phase 11 defines the mapping only.

### Events
- New event created → event_created
- Upcoming event → event_reminder

### Mentorship
- New request → mentorship_request_new
- Request approved / declined → mentorship_request_decision
- New chat message → mentorship_chat_message

### Study Groups
- Group created → study_group_created
- New message → study_group_message

### Gamification
- Level up → level_up
- Badge unlocked → badge_unlocked

### Admin / System
- Admin announcement → admin_announcement
- Profile reminder → profile_completion_reminder
- Feature update → feature_update

---

## 4. Payload Rules (Important)

- Notifications must not contain sensitive data
- Chat message content must never be included
- Payloads should contain context, not full data

Required payload fields:
- title
- body
- type
- referenceId
- sentAt

Payload structure is defined in:
helpers/notification_payload_helpers.dart

---

## 5. Deep-Link Routing

When a notification is tapped, the app should navigate based on type:

- event_* → Event details (eventId = referenceId)
- mentorship_chat_message → Mentorship chat screen
- mentorship_request_* → Mentorship requests screen
- study_group_* → Study group screen
- level_up / badge_unlocked → Gamification screen
- admin_announcement → Announcements / home screen

Routing logic lives in the app layer,
not in notification services.

---

## 6. What Phase 11 Does NOT Do

- No Firebase rules enforcement
- No RBAC checks
- No notification sending implementation
- No Cloud Functions yet

This document is a contract for future phases.