import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

// Firebase & backend debug screens
import 'firebase_health_check.dart';
import 'test_resource_backend.dart';
import 'storage_test_screen.dart';

// Resources (real feature screens)
import '../features/resources/screens/resource_list_screen.dart';
import '../features/resources/screens/resource_upload_screen.dart';

// Profile backend debug
import 'developer_tools_profile_test.dart';

// Events backend debug
import 'developer_tools_events_test.dart';

// Mentorship backend debug
import 'developer_tools_mentorship_test.dart';

// Analytics backend debug
import 'developer_tools_analytics_test.dart';

// Notifications debug
import 'developer_tools_notifications_test.dart';

/// Entry point for all developer-only tools and test screens.
/// Not part of the production navigation.
class DeveloperToolsScreen extends StatelessWidget {
  const DeveloperToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('devTools.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionHeader(theme, t.t('devTools.firebase')),
          _navTile(
            context,
            title: t.t('devTools.firebaseHealth'),
            subtitle: t.t('devTools.firebaseHealthDesc'),
            icon: Icons.health_and_safety,
            child: const FirebaseHealthCheckScreen(),
          ),

          _sectionHeader(theme, t.t('devTools.storage')),
          _navTile(
            context,
            title: t.t('devTools.storageTest'),
            subtitle: t.t('devTools.storageTestDesc'),
            icon: Icons.upload_file,
            child: const StorageTestScreen(),
          ),

          _sectionHeader(theme, t.t('devTools.resources')),
          _navTile(
            context,
            title: t.t('devTools.resourceList'),
            subtitle: t.t('devTools.resourceListDesc'),
            icon: Icons.folder,
            child: const ResourceListScreen(),
          ),
          _navTile(
            context,
            title: t.t('devTools.resourceUpload'),
            subtitle: t.t('devTools.resourceUploadDesc'),
            icon: Icons.upload,
            child: const ResourceUploadScreen(),
          ),
          _navTile(
            context,
            title: t.t('devTools.resourceBackend'),
            subtitle: t.t('devTools.resourceBackendDesc'),
            icon: Icons.bug_report,
            child: const ResourceBackendTestScreen(),
          ),

          _sectionHeader(theme, t.t('devTools.profile')),
          _navTile(
            context,
            title: t.t('devTools.profileTest'),
            subtitle: t.t('devTools.profileTestDesc'),
            icon: Icons.person,
            child: const DeveloperToolsProfileTest(),
          ),

          _sectionHeader(theme, t.t('devTools.events')),
          _navTile(
            context,
            title: t.t('devTools.eventsTest'),
            subtitle: t.t('devTools.eventsTestDesc'),
            icon: Icons.event,
            child: const DeveloperToolsEventsTest(),
          ),

          _sectionHeader(theme, t.t('devTools.analytics')),
          _navTile(
            context,
            title: t.t('devTools.analyticsTest'),
            subtitle: t.t('devTools.analyticsTestDesc'),
            icon: Icons.analytics,
            child: const DeveloperToolsAnalyticsTest(),
          ),

          _sectionHeader(theme, t.t('devTools.notifications')),
          _navTile(
            context,
            title: t.t('devTools.notificationsTest'),
            subtitle: t.t('devTools.notificationsTestDesc'),
            icon: Icons.notifications,
            child: const DeveloperToolsNotificationsTest(),
          ),

          _sectionHeader(theme, t.t('devTools.appInfo')),
          _infoTile(t.t('devTools.buildMode'), _buildMode()),
          _infoTile(
            t.t('devTools.platform'),
            Theme.of(context).platform.name,
          ),
        ],
      ),
    );
  }

  /// Section label used to group related debug tools.
  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  /// Navigation tile that opens a debug screen.
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

  /// Displays static app information.
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
    if (isRelease) return 'Release';

    const isProfile = bool.fromEnvironment('flutter.profile');
    if (isProfile) return 'Profile';

    return 'Debug';
  }
}