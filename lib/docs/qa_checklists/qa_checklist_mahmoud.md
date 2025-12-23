# Phase 7 QA Checklist (Mahmoud – Support)

## Navigation & UX
- [ ] Back button works correctly (no dead ends)
- [ ] Tab switching preserves state
- [ ] Consistent screen titles/headers across modules

## States (Loading / Empty / Error)
- [ ] Every list screen has loading state
- [ ] Empty states are meaningful (not blank screens)
- [ ] Error messages are user-friendly (no raw exceptions)

## Dev-only removal
- [ ] No “Dev Home” screen exists
- [ ] No debug navigation shortcuts remain
- [ ] No temporary test buttons/flows remain
- [ ] No console spam / debug prints

## Permissions / Role safety
- [ ] Students cannot access mentor-only tools
- [ ] Mentors cannot access admin-only tools
- [ ] Unauthorized users see safe fallback screens

## Stability
- [ ] No crashes when rapidly navigating tabs
- [ ] No null-based runtime errors in streams
