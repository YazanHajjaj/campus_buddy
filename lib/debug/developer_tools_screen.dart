import 'package:flutter/material.dart';

// Existing debug/testing screens
import '../features/storage/storage_test_screen.dart';
import 'firebase_health_check.dart';
import 'test_resource_backend.dart';

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
          // Firebase tools
          _sectionHeader("Firebase"),
          _navTile(
            context,
            title: "Firebase Health Check",
            subtitle: "Verify Auth / Firestore / Storage",
            icon: Icons.health_and_safety,
            child: const FirebaseHealthCheckScreen(),
          ),

          const SizedBox(height: 8),

          // Storage tests
          _sectionHeader("Storage"),
          _navTile(
            context,
            title: "Storage Upload Test",
            subtitle: "Pick → Upload → Get URL",
            icon: Icons.upload_file,
            child: const StorageTestScreen(),
          ),

          const SizedBox(height: 8),

          // Resource backend tests
          _sectionHeader("Resource Backend"),
          _navTile(
            context,
            title: "Resource Backend Test",
            subtitle: "CRUD + counters + queries",
            icon: Icons.folder,
            child: const ResourceBackendTestScreen(),
          ),

          const SizedBox(height: 8),

          // Coming soon sections (disabled)
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

  // Section title
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

  // Navigation tile
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

  // Disabled tile for future modules
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

  // Generic info tile
  Widget _infoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  // Determines build mode
  String _buildMode() {
    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease) return "Release";

    const isProfile = bool.fromEnvironment('flutter.profile');
    if (isProfile) return "Profile";

    return "Debug";
  }
}
