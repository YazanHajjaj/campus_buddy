# Phase 9 — Gamification Paths & Contracts

This document defines **where gamification data lives**, **how it is updated**, and  
**what Phase 9 is responsible for**.

Phase 9 is declarative and contract-based.  
No feature logic is implemented here.

---

## 1. Ownership & Scope

Phase 9:
- Defines XP, badge, achievement, and leaderboard structures
- Consumes analytics data (read-only)
- Does NOT own activity tracking
- Does NOT mutate other feature data

Other phases:
- Phase 8 (Analytics) → activity counts, streaks, usage metrics
- Phase 10 (Security) → access control
- Phase 11 (Notifications) → badge / level notifications

---

## 2. Firestore Structure (Proposed)

### User Gamification Root
All gamification-related user state lives under this subtree.

---

### XP State
Fields:
- totalXp: number
- level: number
- lastEarnedFrom: string (xp rule key)
- lastUpdatedAt: timestamp

Notes:
- XP is cumulative
- XP updates are aggregated
- No realtime XP listeners

---

### Badges
Fields:
- id
- title
- description
- icon
- unlocked: boolean
- unlockedAt: timestamp | null

Notes:
- All badges exist for every user
- Locked vs unlocked is explicit
- Badges are never removed or downgraded

---

### Achievements

Fields:
- id
- title
- description
- requiredCount
- currentCount
- completed: boolean
- completedAt: timestamp | null

Notes:
- Progress is numeric and monotonic
- Completion is irreversible
- Progress comes from analytics aggregation

---

## 3. Leaderboards

### Collection
Fields:
- uid
- name
- profileImage
- score (XP or derived metric)
- rank

Notes:
- Leaderboards are aggregated and cached
- No per-request computation
- Ranking window is stable per refresh cycle

---

## 4. Update Strategy

### XP
- Triggered by XP action registration
- Daily caps enforced by aggregation layer
- Level derived from totalXp

### Badges
- Evaluated after XP or analytics updates
- Unlocks are one-time
- No re-locking or downgrade logic

### Achievements
- Progress updated from analytics counters
- Completion is permanent

### Leaderboards
- Updated on a schedule (daily recommended)
- Not realtime
- No live rank churn

---

## 5. Dependencies

Phase 9 reads from:
- Analytics counters (Phase 8)
- User profile basics (name, profile image)

Phase 9 does NOT:
- Track activity
- Modify events, mentorship, or resources
- Send notifications
- Enforce security rules

---

## 6. Phase Rules (Locked)

- No UI wiring in Phase 9
- No analytics schema changes
- No security rules
- No notifications
- No cross-feature writes

Phase 9 ends when:
- Models are complete
- Services are defined
- XP and badge rules are documented
- Firestore paths are locked

Implementation begins in later phases.