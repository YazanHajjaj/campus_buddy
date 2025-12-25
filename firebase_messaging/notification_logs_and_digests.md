# Phase 11 (Optional) — Notification Logs & Digest Plan (Mahmoud)

## Purpose (Optional)
Track notification delivery + provide digest summaries (daily/weekly) in the future.

## Suggested Log Data (store minimal info)
- uid
- type (event_reminder, mentorship_message, badge_unlocked, etc.)
- referenceId (eventId/chatId/groupId)
- createdAt
- delivered (bool) / openedAt (optional)
- channel (push/local)

## Proposed Storage (Optional)
- users/{uid}/notificationLogs/{logId}
  - keep only metadata, no sensitive message content

## Digest Idea (Future)
- daily digest: group by type
- weekly digest: top highlights
- user can opt-in via preferences later

## Notes
- This is OPTIONAL and should not block Phase 11 core FCM setup.
