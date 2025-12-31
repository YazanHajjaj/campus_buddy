⸻

🎓 Campus Buddy

Campus Buddy is a cross-platform university assistant application built with Flutter + Firebase.
It centralizes essential campus services such as profiles, resources, events, mentorship, analytics, and gamification into a single, scalable mobile app.

The project is developed as part of the Software Engineering course at Istanbul Medipol University.

⸻

🚀 Current Status

All core Firebase infrastructure is implemented and tested on:
•	✅ iOS
•	✅ Android
•	✅ macOS

✔ Implemented & Stable

Firebase & Backend
•	Firebase Core initialization
•	Firebase Authentication
•	Anonymous sign-in (development/testing)
•	Email & password login / registration
•	Firestore User Profiles
•	Automatic user document creation
•	Role support (student / mentor / admin)
•	Timestamps and metadata tracking
•	Firebase Storage
•	File uploads (real device)
•	Simulator-safe dummy uploads
•	Analytics & Gamification foundations
•	Notifications architecture
•	Clean modular architecture
•	Developer diagnostic tools

Debug & Testing Tools
Accessible via:

Home → AppBar Menu → Developer Tools

Includes:
•	Firebase Health Check
•	Storage Upload Test
•	Resource Backend Test
•	App diagnostics

⸻

⏳ Planned / In Progress
•	Cloud Functions (Phase 2)
•	Resource Library UI (Phase 3)
•	Mentorship & Events modules (Phase 4–6)
•	Gamification & Analytics completion (Phase 7–10)

⸻

🧩 Features Overview

🔐 Authentication & Profiles
•	Anonymous login (development)
•	Email/password authentication
•	Firestore-backed user profiles
•	Role system (student / mentor / admin)
•	Live profile updates
•	Profile image upload

📦 Resource Library
•	Upload documents to Firebase Storage
•	Backend complete
•	Upcoming:
•	Resource listing UI
•	Bookmarks
•	Offline support

🤝 Mentorship
•	Mentor matching (planned)
•	Study groups
•	Mentorship chats
•	Feedback system

📅 Events
•	Campus events
•	Calendar view
•	RSVP system
•	Event notifications
•	Attendance tracking

🏆 Gamification
•	XP system
•	Badges
•	Leaderboards
•	Streaks & milestones
•	Gamification notifications

📊 Analytics
•	Student engagement tracking
•	Admin dashboards
•	Exportable reports

⸻

🛠️ Tech Stack

Area	Technology
Framework	Flutter 3.x
Language	Dart
Backend	Firebase
Auth	Firebase Authentication
Database	Cloud Firestore
Storage	Firebase Storage
Architecture	Clean Modular Architecture
Platforms	iOS, Android, macOS


⸻

📁 Project Structure

lib/
├─ core/
│   ├─ auth/
│   ├─ localization/
│   ├─ models/
│   ├─ services/
│   └─ security/
├─ features/
│   ├─ analytics/
│   ├─ events/
│   ├─ gamification/
│   ├─ mentorship/
│   ├─ profile/
│   └─ resources/
├─ debug/
│   ├─ developer_tools_screen.dart
│   ├─ firebase_health_check.dart
│   ├─ storage_test_screen.dart
│   └─ test_resource_backend.dart
├─ utils/
├─ firebase_options.dart
└─ main.dart

Folder Responsibilities

Folder	Purpose
core/	Global logic, services, localization, security
features/	Independent app modules
debug/	Developer-only diagnostic tools
utils/	Helper utilities
main.dart	App bootstrap & routing


⸻

🧭 How to Run the Project (Step-by-Step)

1️⃣ Prerequisites

Make sure you have:
•	Flutter SDK (3.x)
•	Dart SDK
•	Firebase account
•	Android Studio / Xcode (for mobile builds)

Verify Flutter:

flutter doctor


⸻

2️⃣ Clone the Repository

git clone https://github.com/<your-username>/campus_buddy.git
cd campus_buddy


⸻

3️⃣ Install Dependencies

flutter pub get


⸻

4️⃣ Firebase Setup

This project uses FlutterFire.

If firebase_options.dart is not present:

flutterfire configure

Select:
•	Firebase project
•	Platforms (iOS, Android, macOS)

This will generate:

lib/firebase_options.dart


⸻

5️⃣ Platform Configuration

iOS

cd ios
pod install
cd ..

Open ios/Runner.xcworkspace in Xcode if needed.

Android
No extra steps required beyond FlutterFire configuration.

⸻

6️⃣ Run the App

flutter run

Or specify platform:

flutter run -d ios
flutter run -d android
flutter run -d macos


⸻

7️⃣ Test Firebase & Backend

Inside the app:

Home → AppBar Menu → Developer Tools

Run:
•	Firebase Health Check
•	Storage Test
•	Resource Backend Test

⸻

🧵 Git Workflow (Team Sentinel Standard)

Branching Strategy

main           → stable & reviewed
feature/*      → new features
bugfix/*       → bug fixes
refactor/*     → code improvements

Rules
•	❌ Never push directly to main
•	✅ Every task = its own branch
•	✅ Pull Requests required
•	✅ Only the team leader merges to main

Start Working

git checkout main
git pull origin main
git checkout -b feature/your-task-name


⸻

👥 Team Sentinel — Contributors

Developed for Software Engineering
Istanbul Medipol University

Name	Role
Yazan Hajjaj	Team Leader, Backend, Firebase, Security
Mahmoud Lkhleif	Database & Backend
Nour Acheche	UI/UX Designer
Shahd Soltan	Frontend Developer, Testing
Ahmed Zahra	Frontend Developer, Testing

Each member contributes across multiple modules including events, mentorship, analytics, resources, and gamification.

⸻

📌 Notes for Evaluators
•	The project follows clean architecture principles
•	Firebase rules and structure are designed for scalability
•	Debug tools are intentionally included for demonstration and testing
•	Code is modular, readable, and production-ready

⸻

🎉 Thank You

Thank you for reviewing Campus Buddy.
For questions or issues, please open a GitHub issue or contact the project maintainer.

Happy coding 🚀