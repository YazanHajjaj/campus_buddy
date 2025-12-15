import 'package:flutter/material.dart';

// Firebase & backend debug screens
import 'firebase_health_check.dart';
import 'test_resource_backend.dart';
import '../features/storage/storage_test_screen.dart';

// UI (Phase 2)
import '../features/resources/screens/resource_list_screen.dart';
import '../features/resources/upload.dart';

// Profile backend debug (Phase 3)
import 'developer_tools_profile_test.dart';

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
          //  Firebase
          _sectionHeader("Firebase"),
          _navTile(
            context,
            title: "Firebase Health Check",
            subtitle: "Verify Auth / Firestore / Storage",
            icon: Icons.health_and_safety,
            child: const FirebaseHealthCheckScreen(),
          ),

          const SizedBox(height: 8),

          //  Storage
          _sectionHeader("Storage"),
          _navTile(
            context,
            title: "Storage Upload Test",
            subtitle: "Pick → Upload → Get URL",
            icon: Icons.upload_file,
            child: const StorageTestScreen(),
          ),

          const SizedBox(height: 8),

          //  Resource backend
          _sectionHeader("Resource Backend"),
          _navTile(
            context,
            title: "Resource Backend Test",
            subtitle: "CRUD + counters",
            icon: Icons.folder,
            child: const ResourceBackendTestScreen(),
          ),

          const SizedBox(height: 8),

          //  Static UI (Phase 2)
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

          //  Profile backend (Phase 3)
          _sectionHeader("Profile Backend"),
          _navTile(
            context,
            title: "Profile Backend Test",
            subtitle: "Firestore + Storage + Stream",
            icon: Icons.person,
            child: const DeveloperToolsProfileTest(),
          ),

          const SizedBox(height: 8),

          //  Coming soon
          _sectionHeader("Events"),
          _disabledTile(
            title: "Event Module Testing",
            subtitle: "Coming in Phase 4",
            icon: Icons.event,
          ),

          const SizedBox(height: 8),

          _sectionHeader("Mentorship"),
          _disabledTile(
            title: "Mentorship Module Testing",
            subtitle: "Coming in Phase 5",
            icon: Icons.people,
          ),

          const SizedBox(height: 8),

          _sectionHeader("Notifications"),
          _disabledTile(
            title: "Notifications Debugger",
            subtitle: "Coming in Phase 9",
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
