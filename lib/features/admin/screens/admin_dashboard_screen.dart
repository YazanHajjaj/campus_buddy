import 'package:flutter/material.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

// Admin feature screens
import 'manage_events_screen.dart';
import 'manage_users_screen.dart';
import 'manage_resources_screen.dart';

// Debug / developer tools
import 'package:campus_buddy/debug/developer_tools_screen.dart';
import 'package:campus_buddy/debug/developer_tools_analytics_test.dart';
import 'package:campus_buddy/debug/developer_tools_events_test.dart';
import 'package:campus_buddy/debug/developer_tools_mentorship_test.dart';
import 'package:campus_buddy/debug/developer_tools_notifications_test.dart';
import 'package:campus_buddy/debug/developer_tools_profile_test.dart';
import 'package:campus_buddy/debug/firebase_health_check.dart';
import 'package:campus_buddy/debug/storage_test_screen.dart';
import 'package:campus_buddy/debug/test_resource_backend.dart';
import 'package:campus_buddy/debug/upload_screen_debug.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('admin.dashboard'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───────────────── ADMIN ACTIONS ─────────────────
          Text(
            t.t('admin.actions'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          _AdminTile(
            icon: Icons.calendar_month,
            title: t.t('admin.manageEvents'),
            subtitle: t.t('admin.manageEventsDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageEventsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.people,
            title: t.t('admin.manageUsers'),
            subtitle: t.t('admin.manageUsersDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageUsersScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.bookmark_outline,
            title: t.t('admin.manageResources'),
            subtitle: t.t('admin.manageResourcesDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageResourcesScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // ───────────────── DEVELOPER / DEBUG TOOLS ─────────────────
          Text(
            t.t('admin.developerTools'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          _AdminTile(
            icon: Icons.build_outlined,
            title: t.t('admin.devOverview'),
            subtitle: t.t('admin.devOverviewDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeveloperToolsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.analytics_outlined,
            title: t.t('admin.devAnalytics'),
            subtitle: t.t('admin.devAnalyticsDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DeveloperToolsAnalyticsTest(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.event_note_outlined,
            title: t.t('admin.devEvents'),
            subtitle: t.t('admin.devEventsDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DeveloperToolsEventsTest(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.school_outlined,
            title: t.t('admin.devMentorship'),
            subtitle: t.t('admin.devMentorshipDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DeveloperToolsMentorshipTestScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.notifications_outlined,
            title: t.t('admin.devNotifications'),
            subtitle: t.t('admin.devNotificationsDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DeveloperToolsNotificationsTest(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.person_outline,
            title: t.t('admin.devProfile'),
            subtitle: t.t('admin.devProfileDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const DeveloperToolsProfileTest(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.storage_outlined,
            title: t.t('admin.devStorage'),
            subtitle: t.t('admin.devStorageDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StorageTestScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.cloud_done_outlined,
            title: t.t('admin.devFirebase'),
            subtitle: t.t('admin.devFirebaseDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FirebaseHealthCheckScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _AdminTile(
            icon: Icons.upload_file_outlined,
            title: t.t('admin.devUpload'),
            subtitle: t.t('admin.devUploadDesc'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ───── FOOTER NOTE ─────
          Text(
            t.t('admin.futureWorkNote'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.disabledColor),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── ADMIN TILE ───────────────── */

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
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              theme.colorScheme.primary.withOpacity(0.12),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.disabledColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}