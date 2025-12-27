import 'package:flutter/material.dart';

// Firebase & backend debug screens
import 'firebase_health_check.dart';
import 'test_resource_backend.dart';
import 'storage_test_screen.dart';

// Resources (REAL SCREENS)
import '../features/resources/screens/resource_list_screen.dart';
import '../features/resources/screens/resource_upload_screen.dart';

// Profile backend debug (Phase 3)
import 'developer_tools_profile_test.dart';

// Events backend debug (Phase 4)
import 'developer_tools_events_test.dart';

// Mentorship backend debug (Phase 5)
import 'developer_tools_mentorship_test.dart';

// Analytics backend debug (Phase 8)
import 'developer_tools_analytics_test.dart';

// Notifications debug (Phase 11)
import 'developer_tools_notifications_test.dart';

class DeveloperToolsScreen extends StatelessWidget {
  const DeveloperToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Developer Tools"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionHeader("Firebase"),
          _navTile(
            context,
            title: "Firebase Health Check",
            subtitle: "Verify Auth / Firestore / Storage",
            icon: Icons.health_and_safety,
            child: const FirebaseHealthCheckScreen(),
          ),

          _sectionHeader("Storage"),
          _navTile(
            context,
            title: "Storage Upload Test",
            subtitle: "Pick → Upload → Get URL",
            icon: Icons.upload_file,
            child: const StorageTestScreen(),
          ),

          _sectionHeader("Resources"),
          _navTile(
            context,
            title: "Resource List (Live)",
            subtitle: "Firestore + filters + viewer",
            icon: Icons.folder,
            child: const ResourceListScreen(),
          ),
          _navTile(
            context,
            title: "Upload Resource",
            subtitle: "Firebase Storage + Firestore",
            icon: Icons.upload,
            child: const ResourceUploadScreen(),
          ),
          _navTile(
            context,
            title: "Resource Backend Test",
            subtitle: "CRUD + counters",
            icon: Icons.bug_report,
            child: const ResourceBackendTestScreen(),
          ),

          _sectionHeader("Profile Backend"),
          _navTile(
            context,
            title: "Profile Backend Test",
            subtitle: "Firestore + Storage + Stream",
            icon: Icons.person,
            child: const DeveloperToolsProfileTest(),
          ),

          _sectionHeader("Events Backend"),
          _navTile(
            context,
            title: "Event Backend Test",
            subtitle: "Create, RSVP, stream, capacity",
            icon: Icons.event,
            child: const DeveloperToolsEventsTest(),
          ),

          _sectionHeader("Mentorship Backend"),
          _navTile(
            context,
            title: "Mentorship Backend Test",
            subtitle: "Profiles, requests, sessions",
            icon: Icons.people,
            child: const DeveloperToolsMentorshipTest(),
          ),

          _sectionHeader("Analytics Backend"),
          _navTile(
            context,
            title: "Analytics Backend Test",
            subtitle: "Student & admin stats",
            icon: Icons.analytics,
            child: const DeveloperToolsAnalyticsTest(),
          ),

          _sectionHeader("Notifications"),
          _navTile(
            context,
            title: "Notifications Debug",
            subtitle: "Payloads & routing",
            icon: Icons.notifications,
            child: const DeveloperToolsNotificationsTest(),
          ),

          _sectionHeader("App Info"),
          _infoTile("Build Mode", _buildMode()),
          _infoTile("Platform", Theme.of(context).platform.name),
        ],
      ),
    );
  }

  // ================= helpers =================

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _navTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Widget child,
      }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => child),
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  String _buildMode() {
    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease) return "Release";

    const isProfile = bool.fromEnvironment('flutter.profile');
    if (isProfile) return "Profile";

    return "Debug";
  }
}