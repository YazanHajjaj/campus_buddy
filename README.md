# 🎓 Campus Buddy
A cross-platform university assistant app built with **Flutter + Firebase**, designed to support students, mentors, and admins with a rich set of campus-focused tools.

---

## 🚀 Current Status (Updated Today)

All core Firebase systems are now fully connected and tested on **iOS, Android, and macOS**:

- ✅ Firebase Core initialization
- ✅ Firebase Authentication
    - Anonymous sign-in
    - Email/password login & registration
- ✅ Firestore user profile system
    - Automatic user upsert (role, email, timestamps)
    - Clean `AppUser` model
- ✅ Firebase Storage
    - Reliable file uploads
    - Real-device file picker support
    - iOS Simulator dummy uploads
- ✅ Diagnostic Tools
    - Firebase Health Check screen
    - Firestore Test Service
- 🧹 Clean and modular project structure
- 🛠 Code cleanup & consistent service architecture

Remaining major backend task:
- ⏳ Cloud Functions (Phase 2)

---

## 🧩 Features (Modules Overview)

### 🔐 **Core**
- Authentication (anonymous + email/password)
- User profile creation & synchronization via Firestore
- RBAC (Role-Based Access Control) ready
- Global validators and security helpers

### 📦 **Resources**
- Upload and store PDFs/files to Firebase Storage
- (Coming soon) Resource library, bookmarks, scanner tools, offline mode

### 🤝 **Mentorship**
- Matching & availability (planned)
- Study groups
- Mentor chat models
- Feedback & reminders

### 🏆 **Gamification**
- Badges
- Leaderboards
- Peer engagement metrics
- Progress tracking
- Rewards system

### 📅 **Events**
- Campus calendar
- Event notifications
- Event security checks

### 📊 **Analytics**
- Student dashboard
- Admin dashboard
- Exporting & reporting tools

### 🧪 **Debug Tools**
- Firebase Health Check (core/auth/firestore/storage)
- Storage Upload Test Screen (real device + simulator modes)

---

## 🛠️ Tech Stack

- **Flutter 3.x**
- **Dart**
- **Firebase**
    - Authentication
    - Firestore
    - Storage
    - (Upcoming) Cloud Functions, Messaging
- Clean Architecture
- Service-based modular layering
- Cross-platform (iOS, Android, macOS)

---
---
## 📁 Project Structure (Clean Architecture)

```text
lib/
  core/
    auth/
    models/
    security/
    services/
  debug/
    firebase_health_check.dart
  features/
    analytics/
    events/
    gamification/
    mentorship/
    resources/
    storage/
  utils/
  firebase_options.dart
  main.dart
```


---

👥 Team Sentinel — Project Contributors

This project is developed by Team Sentinel for the Software Engineering Project at Istanbul Medipol University.


| Name                | Role                                                            |
| ------------------- | --------------------------------------------------------------- |
| **Yazan Hajjaj**    | Team Leader, Back-end Developer, Firebase Integration, Security |
| **Mahmoud Lkhleif** | Database Administrator (DBA), Back-end Developer                |
| **Nour Acheche**    | UI/UX Designer, Front-end Developer                             |
| **Shahd Soltan**    | Front-end Developer, Tester                                     |
| **Ahmed Zahra**     | Front-end Developer, Tester                                     |

👏 Acknowledgment:
Every team member contributes to the design, development, and testing of multiple modules (mentorship, resources, analytics, events, gamification).
