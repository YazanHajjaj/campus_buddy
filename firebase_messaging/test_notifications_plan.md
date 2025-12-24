# Notification Testing Plan — Phase 11

This document defines how notifications are tested in Campus Buddy.
It focuses on client-side behavior, payload handling, and navigation,
not on server-side sending logic.

---

## 1. Test Environment

- Firebase project: development environment
- Test users:
    - Student account
    - Mentor account
- Devices:
    - Android physical device
    - iOS simulator or device (if available)

Notifications may be triggered manually or using test payloads.

---

## 2. Notification States to Test

Each notification type must be tested in the following app states:

1. App in foreground
2. App in background
3. App terminated (cold start)

Expected behavior:
- Foreground → handled by local notification service
- Background → system notification shown
- Terminated → app opens and routes correctly

---

## 3. Event Notifications

### 3.1 Event Created
Type: `event_created`

Steps:
1. Ensure notifications are enabled for events
2. Trigger an event-created notification (test payload)
3. Tap the notification

Expected:
- Notification appears with title and body
- App opens Event Details screen
- Correct event is loaded using referenceId

---

### 3.2 Event Reminder
Type: `event_reminder`

Steps:
1. Ensure event reminders are enabled
2. Trigger reminder notification
3. Tap the notification

Expected:
- Notification appears at correct time
- App opens Event Details screen
- No sensitive event data in payload

---

## 4. Mentorship Notifications

### 4.1 New Mentorship Request
Type: `mentorship_request_new`

Expected:
- Mentor receives notification
- App opens mentorship requests screen
- No student private data in payload

---

### 4.2 Mentorship Decision
Type: `mentorship_request_decision`

Expected:
- Student receives decision notification
- App opens mentorship status screen
- Approved / declined handled correctly

---

### 4.3 Mentorship Chat Message
Type: `mentorship_chat_message`

Expected:
- Notification does NOT contain message text
- App opens correct chat using chatId
- Chat loads messages from backend

---

## 5. Study Group Notifications

### 5.1 Group Created
Type: `study_group_created`

Expected:
- Members receive notification
- App opens study group screen

---

### 5.2 Group Message
Type: `study_group_message`

Expected:
- Notification shown without message content
- App opens correct group chat

---

## 6. Gamification Notifications

### 6.1 Level Up
Type: `level_up`

Expected:
- Notification shown once per level
- App opens gamification / achievements screen

---

### 6.2 Badge Unlocked
Type: `badge_unlocked`

Expected:
- Notification shown once per badge
- App opens badge details or achievements screen

---

## 7. Admin & System Notifications

### 7.1 Admin Announcement
Type: `admin_announcement`

Expected:
- Notification shown to all users
- App opens announcements or home screen

---

### 7.2 System Notification
Type: `profile_completion_reminder`, `feature_update`

Expected:
- Notification shown with generic content
- App opens relevant screen or dashboard

---

## 8. Preferences Testing

Steps:
1. Disable a notification category
2. Trigger notification of that type

Expected:
- Notification is NOT shown
- No background errors
- Other categories still work

---

## 9. Negative & Edge Cases

- Invalid payload type → notification ignored safely
- Missing referenceId → app opens default screen
- Notifications disabled at OS level → app handles gracefully
- Multiple notifications received rapidly → no crashes

---

## 10. Logging & Debugging

- Log payloads in debug mode only
- Verify correct type and referenceId
- No sensitive data logged

---

## 11. Out of Scope

- Cloud Functions sending logic
- Rate limiting
- Delivery guarantees
- Push retry logic