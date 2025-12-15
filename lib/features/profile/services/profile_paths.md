# Profile Backend – Paths & Conventions

This file describes how user profile data is stored in Firestore and Firebase Storage.
Used by all modules that interact with user accounts.

---

## Firestore

Collection:
users/{uid}

Example:
users/4fj392ks8dj20

Fields:
name: string
email: string
bio: string
department: string
profileImageUrl: string (download URL)
createdAt: timestamp
updatedAt: timestamp

Notes:
- Documents are merged on update.
- updatedAt is always set with serverTimestamp().
- Watchers use snapshots().stream for real-time updates.

---

## Firebase Storage

Profile image path:
users/{uid}/profile.jpg

Example:
users/4fj392ks8dj20/profile.jpg

Notes:
- Only one profile image is stored (same file path).
- Uploading a new image overwrites the old one.
- After upload, the download URL is written back to Firestore.

