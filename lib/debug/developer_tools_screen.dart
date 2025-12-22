import 'package:flutter/material.dart';

// Firebase & backend debug screens
import 'firebase_health_check.dart';
import 'test_resource_backend.dart';
import 'storage_test_screen.dart';

// UI (Phase 2)
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
          // Firebase
          _sectionHeader("Firebase"),
          _navTile(
            context,
            title: "Firebase Health Check",
            subtitle: "Verify Auth / Firestore / Storage",
            icon: Icons.health_and_safety,
            child: const FirebaseHealthCheckScreen(),
          ),

          const SizedBox(height: 8),

          // Storage
          _sectionHeader("Storage"),
          _navTile(
            context,
            title: "Storage Upload Test",
            subtitle: "Pick → Upload → Get URL",
            icon: Icons.upload_file,
            child: const StorageTestScreen(),
          ),

          const SizedBox(height: 8),

          // Resource backend
          _sectionHeader("Resource Backend"),
          _navTile(
            context,
            title: "Resource Backend Test",
            subtitle: "CRUD + counters",
            icon: Icons.folder,
            child: const ResourceBackendTestScreen(),
          ),

          const SizedBox(height: 8),

          // Static UI (Phase 2)
          _sectionHeader("UI Screens (Static)"),
          _navTile(
            context,
            title: "Resource List Screen",
            subtitle: "Static UI (Phase 2)",
            icon: Icons.list,
            child: const ResourceListScreen(),
          ),
          _navTile(
            context,
            title: "Upload Resource Screen",
            subtitle: "Static UI (Phase 2)",
            icon: Icons.upload,
            child: const UploadScreen(),
          ),

          const SizedBox(height: 8),

          // Profile backend (Phase 3)
          _sectionHeader("Profile Backend"),
          _navTile(
            context,
            title: "Profile Backend Test",
            subtitle: "Firestore + Storage + Stream",
            icon: Icons.person,
            child: const DeveloperToolsProfileTest(),
          ),

          const SizedBox(height: 8),

          // Events backend (Phase 4)
          _sectionHeader("Events Backend"),
          _navTile(
            context,
            title: "Event Backend Test",
            subtitle: "Create, RSVP, stream, capacity",
            icon: Icons.event,
            child: const DeveloperToolsEventsTest(),
          ),

          const SizedBox(height: 8),

          // Mentorship backend (Phase 5)
          _sectionHeader("Mentorship Backend"),
          _navTile(
            context,
            title: "Mentorship Backend Test",
            subtitle: "Profiles, requests, sessions, chat, groups",
            icon: Icons.people,
            child: const DeveloperToolsMentorshipTest(),
          ),

          const SizedBox(height: 8),

          // Analytics backend (Phase 8)
          _sectionHeader("Analytics Backend"),
          _navTile(
            context,
            title: "Analytics Backend Test",
            subtitle: "Student stats, admin stats, exports",
            icon: Icons.analytics,
            child: const DeveloperToolsAnalyticsTest(),
          ),

          const SizedBox(height: 8),

          // Notifications (future)
          _sectionHeader("Notifications"),
          _disabledTile(
            title: "Notifications Debugger",
            subtitle: "Coming in Phase 11",
            icon: Icons.notifications,
          ),

          const SizedBox(height: 8),

          // App info
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

  Widget _disabledTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      color: Colors.grey.shade300,
      child: ListTile(
        enabled: false,
        leading: Icon(icon, color: Colors.grey),
        title: Text(title, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
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