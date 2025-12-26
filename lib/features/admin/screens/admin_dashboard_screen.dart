import 'package:flutter/material.dart';

import 'manage_events_screen.dart';
import 'manage_users_screen.dart';
import 'manage_resources_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Admin Actions", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          _AdminTile(
            icon: Icons.calendar_month,
            title: "Manage Events",
            subtitle: "Approve, edit, or delete events",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageEventsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.people,
            title: "Manage Users",
            subtitle: "View and control user access",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.bookmark,
            title: "Manage Resources",
            subtitle: "Review uploaded materials",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageResourcesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
