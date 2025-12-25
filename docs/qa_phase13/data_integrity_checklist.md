# Phase 13 — Data Integrity Checklist (Mahmoud)

## Status
WAIT — run only after analytics + gamification are stable.

## Data Integrity Checks
### Resources
- [ ] Resource count matches Firestore documents
- [ ] Upload adds exactly 1 document + storage file
- [ ] Delete removes document and file (if supported)
- [ ] No duplicate records for same resourceId

### Events
- [ ] Event attendance count matches RSVP subcollection count
- [ ] RSVP toggling updates counts correctly
- [ ] Capacity limits enforced (if implemented)
- [ ] Past events handled correctly (not duplicated / wrong ordering)

### Gamification (XP / Badges / Leaderboard)
- [ ] XP increments match xp_rules.dart expectations
- [ ] Badge unlock conditions match badge_rules_helpers.dart
- [ ] Leaderboard ordering is correct (including tie-breaking)
- [ ] No negative XP or impossible states

## Evidence to attach when executed
- Screenshots from UI
- Firestore sample documents (redact private info)
- Notes about discrepancies and steps to reproduce
