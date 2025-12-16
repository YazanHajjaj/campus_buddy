# Events Module — Firestore & Storage Paths

This document defines the final data structure for the Events module.
It is used by backend, UI, and query helpers.

---

## Firestore Collections

### events/{eventId}

Main event document.

Fields:
- title (string)
- description (string)
- location (string)
- date (timestamp)          # midnight, used for calendar
- startTime (timestamp)
- endTime (timestamp)
- createdBy (string uid)
- isOnline (bool)
- imageUrl (string, optional)
- tags (array<string>)
- capacity (int)            # 0 = unlimited
- attendeesCount (int)
- isActive (bool)
- createdAt (timestamp)
- updatedAt (timestamp)

---

### events/{eventId}/rsvps/{uid}

Tracks attendance per event.

Fields:
- uid (string)
- eventId (string)
- createdAt (timestamp)

Rules:
- document id = uid
- prevents duplicate RSVP

---

### users/{uid}/rsvps/{eventId} (optional mirror)

Used for:
- user profile → "My Events"
- fast lookup of user RSVPs

Fields:
- eventId (string)
- createdAt (timestamp)

---

## Storage Paths

### /event_images/{eventId}/banner.jpg

- optional banner image
- uploaded by admin only
- imageUrl stored in event document

---

## Security Rules (Conceptual)

- only admins can:
    - create events
    - update events
    - delete events
    - upload banner images

- students can:
    - read active events
    - RSVP to events
    - cancel their own RSVP

- RSVP is blocked if:
    - event is inactive
    - capacity is reached

---

## Filtering & Sorting

Supported filters:
- upcoming events (startTime >= now)
- events by date (calendar)
- events by tag
- events by location

Sorting:
- by startTime (default)
- by date
