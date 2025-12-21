# Mentorship Paths (Phase 5)

This doc is just our reference so the team doesn’t freestyle paths.

## Core collections

### Mentor profiles
mentor_profiles/{mentorId}

Fields:
- userId (same as users/{uid})
- name, photoUrl, bio
- department, faculty
- expertise[]
- isActive
- ratingAvg, ratingCount
- activeMenteesCount
- createdAt, updatedAt

### Mentorship requests
mentorship_requests/{requestId}

Fields:
- studentId
- mentorId
- message (optional)
- status: pending | accepted | rejected | canceled
- createdAt, updatedAt

### Mentorship sessions
mentorship_sessions/{sessionId}

Fields:
- mentorId
- studentId
- scheduledAt (Timestamp)
- durationMinutes
- notes (optional)
- status: scheduled | completed | canceled
- createdAt, updatedAt

### 1-to-1 chats
mentorship_chats/{chatId}

Doc fields:
- mentorId
- studentId
- createdAt, updatedAt
- lastMessageText, lastMessageAt

Messages:
mentorship_chats/{chatId}/messages/{messageId}

Fields:
- chatId
- senderId
- text
- createdAt
- readBy[]  (uids)

### Study groups
study_groups/{groupId}

Fields:
- title
- description (optional)
- createdBy
- tags[]
- memberCount
- maxMembers
- isPrivate
- createdAt, updatedAt
- lastMessageText, lastMessageAt (optional)

Members:
study_groups/{groupId}/members/{uid}

Fields:
- uid
- joinedAt
- role: owner | member

Messages:
study_groups/{groupId}/messages/{messageId}

Same shape as chat messages:
- chatId (groupId)
- senderId
- text
- createdAt
- readBy[]

## Basic rules (high level)
- Mentors update only their mentor_profile doc
- Student can only have 1 active pending request
- Only mentor + student (same ids inside chat doc) can read/write that chat
- Only group members can read/write group messages
