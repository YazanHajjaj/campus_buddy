
---

# 🎓 Campus Buddy

A cross-platform university assistant app built with **Flutter + Firebase**, designed to support students, mentors, and admins with a unified set of campus-focused tools.

---

# 🚀 Current Status

All core Firebase systems are fully implemented and tested on **iOS, Android, and macOS**:

### ✔ Firebase & Backend

* Firebase Core initialization
* Firebase Authentication

    * Anonymous sign-in
    * Email/password login & registration
* Firestore User Profiles

    * Automatic user upsert (role, email, timestamps)
    * Clean and consistent `AppUser` model
* Firebase Storage

    * Real-device file picker
    * iOS Simulator dummy uploads
* Robust Diagnostic Tools

    * Firebase Health Check
    * Resource Backend Test
    * Storage Test Screen
* Clean, modular, scalable architecture
* Stable debug workflow via Developer Tools Menu

### ⏳ Pending / Upcoming

* Cloud Functions (Phase 2)
* Resource Library UI (Phase 3)
* Mentorship & Events (Phase 4–6)
* Gamification & Analytics (Phase 7–10)

---

# 🧩 Features (Modules Overview)

### 🔐 **Core Authentication & Profiles**

* Anonymous login (development)
* Email/password authentication
* Automatic Firestore user profiles
* Role system (student / mentor / admin)
* User metadata tracking

### 📦 **Resource Library**

* Upload PDF/documents to Firebase Storage
* Backend implementation complete
* Upcoming:

    * Resource list UI
    * Bookmarks
    * Scanner tools
    * Offline mode

### 🤝 **Mentorship**

* Mentor matching (planned)
* Mentor availability
* Study groups
* Mentorship chats
* Feedback system

### 🏆 **Gamification**

* Badges
* Leaderboards
* XP system
* Engagement metrics
* Rewards

### 📅 **Events**

* Campus event calendar
* RSVP system
* Event reminders
* Event analytics

### 📊 **Analytics**

* Student dashboard
* Admin reports
* Usage graphs
* Export to CSV/PDF

### 🧪 **Debug Tools**

Accessible via:

```
Home → AppBar Menu → Developer Tools
```

Includes:

* Firebase Health Check
* Storage Upload Test
* Resource Backend Test
* App info diagnostics

---

# 🛠️ Tech Stack

| Area            | Technology                    |
| --------------- | ----------------------------- |
| Framework       | Flutter 3.x                   |
| Language        | Dart                          |
| Backend         | Firebase                      |
| Auth            | Firebase Authentication       |
| Database        | Firestore                     |
| File Storage    | Firebase Storage              |
| Debug Workflows | Custom Developer Tools Screen |
| Architecture    | Clean Modular Architecture    |
| Platforms       | iOS, Android, macOS           |

---

# 📁 Project Structure (Clean Architecture)

```
lib/
  core/
    auth/
    models/
    security/
    services/
  debug/
    developer_tools_screen.dart
    firebase_health_check.dart
    storage_test_screen.dart
    test_resource_backend.dart
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

### Folder Roles

| Folder      | Purpose                                         |
| ----------- | ----------------------------------------------- |
| `core/`     | Global logic (auth, services, models, security) |
| `features/` | All app modules (each fully isolated)           |
| `debug/`    | Developer-only testing tools                    |
| `utils/`    | Helpers and utilities                           |
| `main.dart` | App bootstrap & routing                         |

---

# 🧭 Development Workflow

### 1. Clone the repo

```bash
git clone https://github.com/<your-username>/campus_buddy.git
cd campus_buddy
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. Run Firebase diagnostic tools

Access via Developer Tools.

---

# 🧵 Git Workflow (Team Sentinel Standard)

### Branch Structure

```
main           — stable, reviewed, safe
feature/*      — new feature development
bugfix/*       — bug fixes
refactor/*     — code improvements
```

### Rules

* **NEVER push directly to `main`**
* **Every task = its own branch**
* **Only Yazan merges into main**

### Start working:

```bash
git checkout main
git pull origin main
git checkout -b feature/task-name
```

---

# 👥 Team Sentinel — Contributors

This project is developed for the Software Engineering course at Istanbul Medipol University.

| Name                | Role                                                 |
| ------------------- | ---------------------------------------------------- |
| **Yazan Hajjaj**    | Team Leader, Backend, Firebase Integration, Security |
| **Mahmoud Lkhleif** | Database Administrator, Backend                      |
| **Nour Acheche**    | UI/UX Designer, Front-end                            |
| **Shahd Soltan**    | Front-end Developer, Tester                          |
| **Ahmed Zahra**     | Front-end Developer, Tester                          |

👏 **Acknowledgment:**
Every member contributes to multiple modules including resources, mentorship, analytics, events, and gamification.

---

# 🎉 Thank You for Visiting Campus Buddy!

For issues, suggestions, or contributions, please open a GitHub issue or contact the maintainer.

Happy coding! 🚀

---