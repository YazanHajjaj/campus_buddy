---

# 🚀 **Onboarding Guide — Campus Buddy**

Welcome to **Campus Buddy**!
This guide will help you set up the project, understand the structure, and contribute safely and effectively.

---

# 📦 **1. Project Overview**

Campus Buddy is a multi-module Flutter application designed for students, mentors, and admins.
Core features include:

* Authentication & Profiles
* Resource Library
* Mentorship System
* Events
* Gamification
* Analytics Dashboards
* Cloud Storage & Notifications

Tech stack:

* **Flutter 3.x**
* **Dart**
* **Firebase**
* **Clean Modular Architecture**

---

# 🛠 **2. Required Tools**

## System Requirements

* macOS / Windows / Linux
* Xcode (iOS)
* Android Studio (Android)

## Software Tools

```
flutter --version
```

* Dart
* CocoaPods (macOS/iOS)

## Firebase Tools

Install FlutterFire:

```
dart pub global activate flutterfire_cli
```

---

# 🔧 **3. Setting Up the Project**

Clone repository:

```
git clone https://github.com/<your-username>/campus_buddy.git
cd campus_buddy
```

Install dependencies:

```
flutter pub get
```

Configure Firebase (only if adding new platforms):

```
flutterfire configure
```

The generated file:
`lib/firebase_options.dart`

---

# 📁 **4. Project Structure**

```
lib/
  core/
  debug/
  features/
  utils/
  firebase_options.dart
  main.dart
```

### Folder Overview

| Folder        | Description                                                    |
| ------------- | -------------------------------------------------------------- |
| **core/**     | Global logic (Auth, models, services, security)                |
| **features/** | Feature modules (resources, events, mentorship, gamification…) |
| **debug/**    | Developer testing tools                                        |
| **utils/**    | Helpers and utilities                                          |
| **main.dart** | App entry point                                                |

---

# 🔐 **5. Firebase Integration**

Campus Buddy uses:

* Firebase Auth
* Firestore
* Storage

Implemented:

* Anonymous + email login
* Firestore user profiles
* Storage upload/download
* Firebase health check tools

### Debug Tools

Located in `lib/debug/`:

* `FirebaseHealthCheckScreen`
* `StorageTestScreen`
* `ResourceBackendTestScreen`
* `DeveloperToolsScreen` (central hub)

Menu path:

```
Home → AppBar (three dots) → Developer Tools
```

---

# 👤 **6. AppUser Model**

Each authenticated user is mapped to Firestore:

| Field       | Description          |
| ----------- | -------------------- |
| uid         | Firebase UID         |
| email       | Email (if available) |
| role        | student/mentor/admin |
| isAnonymous | true/false           |
| createdAt   | Timestamp            |
| lastLogin   | Timestamp            |

Automatically synced through:
`AuthService → FirestoreUserService`

---

# 🧱 **7. Code Architecture Guidelines**

### Services

* Contain logic only
* No Flutter imports
* Return clean models

### Models

* Located in `core/models/`
* Must implement `toMap()` and `fromMap()`

### UI Screens

* Do not contain business logic
* Use services for Firestore/Storage

### Comments

* Keep comments technical and minimal

---

# 🌿 **8. Feature Development Workflow**

1. Create a folder in `features/<feature>/`
2. Add your model
3. Add your service (abstract + implementation)
4. Build UI screens
5. Connect UI → service
6. Test using Developer Tools

---

# 🌐 **9. Git Workflow**

### Branch Rules

```
main = stable only
feature/* = new work
bugfix/* = fixes
```

### Important

```
DO NOT commit or push to main.
Only Yazan merges into main.
```

### Starting Work

```
git checkout main
git pull origin main
git checkout -b feature/task-name
```

### Commit Messages

```
feat(auth): add new login method
fix(resources): incorrect Firestore path
chore: update onboarding docs
```

### Pull Requests

Must include:

* What changed
* How to test
* Screenshots (if UI)

---

# 🧪 **10. Common Issues**

### iOS simulator cannot pick files

Use dummy uploads.

### Storage upload fails

Check:

* Rules
* File path
* Network

### Firestore document missing

Use `AuthService().getCurrentAppUser()`.

---

# 🛤 **11. Roadmap for New Contributors**

1. Read this document
2. Run the Developer Tools > Firebase Health Check
3. Test Storage upload
4. Review the folder structure
5. Start with the Resource Library module

---

# 👥 **12. Maintainer (Team Sentinel)**

| Name             | Role                                      |
| ---------------- | ----------------------------------------- |
| **Yazan Hajjaj** | Team Leader, Backend, Firebase & Security |
| Mahmoud Lkhleif  | Database & Backend                        |
| Nour Acheche     | UI/UX & Frontend                          |
| Shahd Soltan     | Frontend & Testing                        |
| Ahmed Zahra      | Frontend & Testing                        |

---

# 🎉 Welcome to Campus Buddy!

Contact the maintainer for help or open a GitHub issue.
Happy building 🚀

---