---

# 🚀 **Onboarding Guide — Campus Buddy**

Welcome to **Campus Buddy**!
This document will get you fully set up as a developer and teach you how to contribute to the project safely, correctly, and consistently.

This is the **official onboarding guide** for all contributors.

---

# 📦 **1. Project Overview**

Campus Buddy is a cross-platform (iOS / Android / macOS) Flutter application designed to support university students, mentors, and admins with:

* Authentication & profiles
* File uploads
* Mentorship system
* Resource library
* Events module
* Gamification
* Analytics dashboards

The project is built with:

* **Flutter 3.x**
* **Dart**
* **Firebase**
* **Clean architecture**
* **Modular folder structure**

---

# 🛠 **2. Required Tools**

Make sure you have the following installed:

## System Requirements

* macOS / Windows / Linux
* Xcode (for iOS)
* Android Studio (for Android)
* VS Code or IntelliJ (optional)

## Software Tools

* Flutter (latest stable)

```bash
flutter --version
```

* Dart
* CocoaPods (for iOS builds)

## Firebase / CLI

* Firebase account
* FlutterFire CLI

Install using:

```bash
dart pub global activate flutterfire_cli
```

---

# 🔧 **3. Setting Up the Project**

## Clone the repository

```bash
git clone https://github.com/<your-username>/campus_buddy.git
cd campus_buddy
```

## Install dependencies

```bash
flutter pub get
```

## Configure Firebase (only needed if adding new platforms)

```bash
flutterfire configure
```

This generates the required `firebase_options.dart`.

---

# 📁 **4. Project Structure**

Campus Buddy follows a **modular clean architecture**:

```
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

### Folder Responsibilities

| Folder                    | What Goes Here                                                                |
| ------------------------- | ----------------------------------------------------------------------------- |
| **core/**                 | Global logic: services, authentication, Firestore, models                     |
| **features/**             | Independent features (resources, mentorship, events, gamification, analytics) |
| **debug/**                | Diagnostic tools and dev-only screens                                         |
| **utils/**                | Small helpers & utilities                                                     |
| **main.dart**             | App entry point                                                               |
| **firebase_options.dart** | Auto-generated Firebase config                                                |

Each feature folder should contain its **own UI, logic, models, and services** where possible.

---

# 🔐 **5. Firebase Integration (Important)**

Campus Buddy uses:

* Firebase Auth
* Cloud Firestore
* Firebase Storage

Already implemented:

* Anonymous login
* Email/password login
* Firestore upsert user profiles
* Storage file upload service
* Firebase health diagnostics

### Debug Tools

Use the following screens for testing:

* **FirebaseHealthCheckScreen**

    * Tests Auth, Firestore, Storage, Core
* **StorageTestScreen**

    * Uploads real files (device)
    * Uploads dummy files (simulator)

---

# 👤 **6. AppUser Flow**

All authenticated users are mapped to a clean Firestore model:

* `uid`
* `email`
* `role` (default: `student`)
* `isAnonymous`
* `createdAt`
* `lastLogin`

This is handled automatically via:

```
AuthService ↔ FirestoreUserService ↔ Firestore
```

No manual creation is ever needed.

---

# 🧱 **7. Code Architecture Guidelines**

### Services (Auth / Firestore / Storage)

* Must only contain logic (no UI).
* Must never import Flutter widgets.
* Should use async/await, not chains.
* Must return clean data models (not raw snapshots).

### Models

* Stored in `core/models/`.
* Must have:

    * constructor
    * `toMap()`
    * `fromMap()`

### UI Screens

* Should not contain business logic.
* Only call services.
* Use controllers or providers later (if needed).

### Comments

* Keep comments technical:

    * “Handles Firestore user creation.”
    * “Uploads file to Firebase Storage.”
* Avoid tutorial explanations.

---

# 🌿 **8. Feature Development Workflow**

This is the recommended way to build **any new feature**.

### Step 1 — Create a folder under `features/`

Example: `features/resources/`

### Step 2 — Create your data model

Example: `resource.dart`

### Step 3 — Create a service

Example: `resource_service.dart`

### Step 4 — Create UI screens

Example:

* `resource_upload_screen.dart`
* `resource_library.dart`

### Step 5 — Connect service → UI

UI should call service methods only.

### Step 6 — Test with debug tools

Use:

* Firebase Health Check
* Storage Test Screen

---

# 🌐 **9. Git Workflow**

### Branching

```
main           = stable
feature/*      = new features
bugfix/*       = fixes
refactor/*     = code improvements
```

### Commit Message Convention

Examples:

```
feat(resources): add resource upload service
fix(auth): resolve login crash on null email
refactor(storage): clean uploadFile API
chore: update README and onboarding docs
```

### Pull Requests

Each PR must include:

* What was added or changed
* How to test the feature
* Screenshots (if UI)

---

# 🧪 **10. Common Issues & Fixes**

### iOS Simulator cannot pick files

This is normal.
Use **Dummy Upload** mode.

### Storage upload returns null

Check:

* Bucket name in `storage_service.dart`
* Firebase rules (auth required)
* Device has network access

### Auth user missing in Firestore

Call `AuthService().getCurrentAppUser()`
or rely on `appUserChanges` stream.

---

# 🛤 **11. Roadmap for New Developers**

If you're joining today, work in this order:

1. Read this ONBOARDING.md
2. Run the Firebase Health Check
3. Test Storage upload
4. Explore the `features/` modules
5. Begin work on the **Resource Library** module

---

# 👥 **12. Maintainer**
This project is developed by Team Sentinel as part of the Software Engineering Project at Istanbul Medipol University.


| Name                | Role                                                            |
| ------------------- | --------------------------------------------------------------- |
| **Yazan Hajjaj**    | Team Leader, Back-end Developer, Firebase Integration, Security |
| **Mahmoud Lkhleif** | Database Administrator (DBA), Back-end Developer                |
| **Nour Acheche**    | UI/UX Designer, Front-end Developer                             |
| **Shahd Soltan**    | Front-end Developer, Tester                                     |
| **Ahmed Zahra**     | Front-end Developer, Tester                                     |

Acknowledgment:

Each member contributes to the development, testing, and refinement of the Campus Buddy application across multiple modules (mentorship, resources, analytics, events, and gamification).

---

# 🎉 Welcome to the project!

If you have questions, open an issue or contact the maintainer.

Happy building! 🚀
Campus Buddy Team

---
