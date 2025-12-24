# Firebase Cloud Messaging — Setup Notes

These notes document how FCM is expected to be configured
for Campus Buddy. This is reference documentation, not a tutorial.

---

## General Notes

- Firebase Cloud Messaging is used for push notifications
- Notifications are sent server-side (Cloud Functions preferred)
- The app only handles:
    - Token registration
    - Permission prompts
    - Local display (foreground)

---

## Android Setup

- Add `firebase_messaging` dependency
- Ensure `google-services.json` is present
- Notification permission is granted by default (Android < 13)
- For Android 13+:
    - Explicit POST_NOTIFICATIONS permission is required
- Default notification channel should be defined

---

## iOS Setup

- Enable Push Notifications capability in Xcode
- Enable Background Modes → Remote notifications
- Upload APNs key or certificates to Firebase Console
- Request notification permission at runtime
- Handle permission denial gracefully

---

## Token Handling

- FCM token is generated per device
- Token should be saved after:
    - App install
    - User login
- Token refresh must be handled
- Multiple tokens per user are expected

Tokens are stored at:
users/{uid}/fcmTokens/{tokenId}

---

## Payload Rules (Reminder)

- Do not include sensitive data
- Do not include full chat messages
- Payloads contain context only
- App fetches full data after navigation

---

## Debug Notes

- Test notifications using Firebase Console
- Log token registration during development
- Use separate test users for multi-device testing

---

## Out of Scope for Phase 11

- Cloud Functions implementation
- Notification rate limiting
- Security enforcement