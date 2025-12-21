# Phase 8 — Analytics & Reporting
Campus Buddy

This document defines the complete scope, data sources, and rules for analytics
in Campus Buddy.

Phase 8 is BACKEND & DATA only.
No UI, no charts, no dashboards, no navigation.

If a metric is not listed here, it does not exist.

---

## 1. Phase 8 Rules (Locked)

- Analytics is read-only and derived from existing modules.
- No new Firestore collections are introduced in Phase 8.
- No UI implementation in this phase.
- No Cloud Functions or background jobs.
- No real-time listeners required (simple reads are enough).
- Aggregation logic lives in services only.
- Models are data contracts only (no logic).

---

## 2. Who Sees What

### 2.1 Student Analytics (per-user, self only)

Students can only see analytics about their own activity.

#### Mentorship
- mentorshipSessionsCount
- mentorshipHoursTotal
- mentorshipLastSessionAt

#### Events
- eventsRsvpCount
- eventsLastRsvpAt

(Note: attendance tracking is not implemented; RSVP is the source of truth.)

#### Resources
- resourcesUploadedCount

(Resource views/downloads are global counters only and are not per-user.)

#### Activity
- lastLogin

---

### 2.2 Admin Analytics (global)

Admins can see aggregate usage across the entire system.

#### Users
- totalUsers
- activeUsersLast7Days
- activeUsersLast30Days

#### Mentorship
- totalMentorshipSessions
- totalMentorshipHours

#### Events
- totalEvents
- totalEventRsvps

#### Resources
- totalResources
- totalResourceUploads
- totalResourceDownloads
- totalResourceViews

---

## 3. Firestore Data Sources

### 3.1 Users

Collection:
- users/{uid}

Fields used:
- role
- createdAt
- lastLogin

Usage:
- totalUsers = count(users)
- activeUsersLastXDays = lastLogin >= now - X days
- student last activity = lastLogin

---

### 3.2 Mentorship

Canonical source:
- mentorship_sessions/{sessionId}

Expected fields:
- studentId
- mentorId
- durationMinutes
- status (completed / canceled)
- completedAt

Student metrics:
- mentorshipSessionsCount =
  count of completed sessions where studentId == uid
- mentorshipHoursTotal =
  sum(durationMinutes) / 60 where studentId == uid
- mentorshipLastSessionAt =
  max(completedAt) where studentId == uid

Admin metrics:
- totalMentorshipSessions =
  count of completed sessions
- totalMentorshipHours =
  sum(durationMinutes) / 60 across all completed sessions

---

### 3.3 Events

Collections:
- events/{eventId}
- events/{eventId}/rsvps/{uid}

RSVP document fields:
- uid
- createdAt
- status (going)

Student metrics:
- eventsRsvpCount =
  count of RSVP docs for uid
- eventsLastRsvpAt =
  max(createdAt)

Admin metrics:
- totalEvents =
  count(events)
- totalEventRsvps =
  count(all RSVP documents)

Attendance is NOT tracked in Phase 8.

---

### 3.4 Resources

Collection:
- resources/{resourceId}

Expected fields:
- uploaderUserId
- createdAt
- downloadCount
- viewCount

Student metrics:
- resourcesUploadedCount =
  count(resources where uploaderUserId == uid)

Admin metrics:
- totalResources =
  count(resources)
- totalResourceUploads =
  count(resources)
- totalResourceDownloads =
  sum(downloadCount)
- totalResourceViews =
  sum(viewCount)

Per-user views/downloads are NOT supported.

---

## 4. Aggregation Strategy

Phase 8 uses a hybrid aggregation approach:

- Simple counters (views, downloads, attendeesCount) are already stored
  at the source documents.
- Analytics services aggregate data on demand using Firestore reads.
- No analytics snapshots or logs are stored.
- No caching is implemented in this phase.

This keeps analytics simple, accurate, and easy to audit.

---

## 5. What Phase 8 Does NOT Include

Explicitly excluded from Phase 8:

- Charts or graphs
- Admin dashboards
- CSV or PDF exports
- Scheduled jobs
- Cloud Functions
- Gamification logic
- Achievements or points
- UI or navigation

These are handled in later phases.

---

## 6. Phase 8 Exit Criteria

Phase 8 is considered DONE when:

- This document is complete and approved
- Analytics models match this scope exactly
- Analytics services read only from documented paths
- No UI references exist
- No additional metrics are added

Once these conditions are met, Phase 8 is locked.