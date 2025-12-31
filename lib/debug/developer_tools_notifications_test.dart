import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../features/notifications/helpers/notification_payload_helpers.dart';

/// Developer-only screen for testing notification payloads.
/// Not part of the production UI.
class DeveloperToolsNotificationsTest extends StatelessWidget {
  const DeveloperToolsNotificationsTest({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('notifications.debugTools')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionHeader(theme, t.t('notifications.events')),
          _payloadTile(
            context,
            title: t.t('notifications.eventCreated'),
            subtitle: 'event_created',
            icon: Icons.event_available,
            payload: NotificationPayload.eventPayload(
              title: 'New Event',
              body: 'A new campus event was created',
              eventId: 'event_test_123',
              type: NotificationPayload.eventCreated,
            ),
          ),
          _payloadTile(
            context,
            title: t.t('notifications.eventReminder'),
            subtitle: 'event_reminder',
            icon: Icons.alarm,
            payload: NotificationPayload.eventPayload(
              title: 'Event Reminder',
              body: 'Your event starts soon',
              eventId: 'event_test_123',
              type: NotificationPayload.eventReminder,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader(theme, t.t('notifications.mentorship')),
          _payloadTile(
            context,
            title: t.t('notifications.mentorshipRequest'),
            subtitle: 'mentorship_request_new',
            icon: Icons.person_add,
            payload: NotificationPayload.mentorshipPayload(
              title: 'New Mentorship Request',
              body: 'A student requested mentorship',
              referenceId: 'request_test_456',
              type: NotificationPayload.mentorshipRequestNew,
            ),
          ),
          _payloadTile(
            context,
            title: t.t('notifications.mentorshipMessage'),
            subtitle: 'mentorship_chat_message',
            icon: Icons.chat,
            payload: NotificationPayload.mentorshipPayload(
              title: 'New Message',
              body: 'You have a new mentorship message',
              referenceId: 'chat_test_789',
              type: NotificationPayload.mentorshipChatMessage,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader(theme, t.t('notifications.studyGroups')),
          _payloadTile(
            context,
            title: t.t('notifications.studyGroupCreated'),
            subtitle: 'study_group_created',
            icon: Icons.group,
            payload: NotificationPayload.studyGroupPayload(
              title: 'New Study Group',
              body: 'You were added to a study group',
              groupId: 'group_test_321',
              type: NotificationPayload.studyGroupCreated,
            ),
          ),
          _payloadTile(
            context,
            title: t.t('notifications.studyGroupMessage'),
            subtitle: 'study_group_message',
            icon: Icons.forum,
            payload: NotificationPayload.studyGroupPayload(
              title: 'New Group Message',
              body: 'A new message was posted',
              groupId: 'group_test_321',
              type: NotificationPayload.studyGroupMessage,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader(theme, t.t('notifications.gamification')),
          _payloadTile(
            context,
            title: t.t('notifications.levelUp'),
            subtitle: 'level_up',
            icon: Icons.trending_up,
            payload: NotificationPayload.gamificationPayload(
              title: 'Level Up!',
              body: 'You reached a new level',
              type: NotificationPayload.levelUp,
            ),
          ),
          _payloadTile(
            context,
            title: t.t('notifications.badgeUnlocked'),
            subtitle: 'badge_unlocked',
            icon: Icons.emoji_events,
            payload: NotificationPayload.gamificationPayload(
              title: 'Badge Unlocked',
              body: 'You unlocked a new badge',
              type: NotificationPayload.badgeUnlocked,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader(theme, t.t('notifications.system')),
          _payloadTile(
            context,
            title: t.t('notifications.adminAnnouncement'),
            subtitle: 'admin_announcement',
            icon: Icons.campaign,
            payload: NotificationPayload.systemPayload(
              title: 'Announcement',
              body: 'University-wide announcement',
              type: NotificationPayload.adminAnnouncement,
            ),
          ),
          _payloadTile(
            context,
            title: t.t('notifications.profileReminder'),
            subtitle: 'profile_completion_reminder',
            icon: Icons.info,
            payload: NotificationPayload.systemPayload(
              title: 'Complete Your Profile',
              body: 'Finish setting up your profile',
              type: NotificationPayload.profileCompletionReminder,
            ),
          ),
        ],
      ),
    );
  }

  /// Section label used to group notification types.
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

  /// Displays a test payload entry.
  Widget _payloadTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Map<String, dynamic> payload,
      }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: () => _showPayloadDialog(context, payload),
      ),
    );
  }

  /// Shows the raw notification payload for inspection.
  void _showPayloadDialog(
      BuildContext context,
      Map<String, dynamic> payload,
      ) {
    final t = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.t('notifications.payload')),
        content: SingleChildScrollView(
          child: Text(payload.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('common.close')),
          ),
        ],
      ),
    );
  }
}