import 'package:flutter/material.dart';

import '../features/notifications/helpers/notification_payload_helpers.dart';

class DeveloperToolsNotificationsTest extends StatelessWidget {
  const DeveloperToolsNotificationsTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications Debug"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionHeader("Events"),
          _payloadTile(
            context,
            title: "Event Created",
            subtitle: "event_created",
            icon: Icons.event_available,
            payload: NotificationPayload.eventPayload(
              title: "New Event",
              body: "A new campus event was created",
              eventId: "event_test_123",
              type: NotificationPayload.eventCreated,
            ),
          ),
          _payloadTile(
            context,
            title: "Event Reminder",
            subtitle: "event_reminder",
            icon: Icons.alarm,
            payload: NotificationPayload.eventPayload(
              title: "Event Reminder",
              body: "Your event starts soon",
              eventId: "event_test_123",
              type: NotificationPayload.eventReminder,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader("Mentorship"),
          _payloadTile(
            context,
            title: "New Mentorship Request",
            subtitle: "mentorship_request_new",
            icon: Icons.person_add,
            payload: NotificationPayload.mentorshipPayload(
              title: "New Mentorship Request",
              body: "A student requested mentorship",
              referenceId: "request_test_456",
              type: NotificationPayload.mentorshipRequestNew,
            ),
          ),
          _payloadTile(
            context,
            title: "Mentorship Chat Message",
            subtitle: "mentorship_chat_message",
            icon: Icons.chat,
            payload: NotificationPayload.mentorshipPayload(
              title: "New Message",
              body: "You have a new mentorship message",
              referenceId: "chat_test_789",
              type: NotificationPayload.mentorshipChatMessage,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader("Study Groups"),
          _payloadTile(
            context,
            title: "Study Group Created",
            subtitle: "study_group_created",
            icon: Icons.group,
            payload: NotificationPayload.studyGroupPayload(
              title: "New Study Group",
              body: "You were added to a study group",
              groupId: "group_test_321",
              type: NotificationPayload.studyGroupCreated,
            ),
          ),
          _payloadTile(
            context,
            title: "Study Group Message",
            subtitle: "study_group_message",
            icon: Icons.forum,
            payload: NotificationPayload.studyGroupPayload(
              title: "New Group Message",
              body: "A new message was posted",
              groupId: "group_test_321",
              type: NotificationPayload.studyGroupMessage,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader("Gamification"),
          _payloadTile(
            context,
            title: "Level Up",
            subtitle: "level_up",
            icon: Icons.trending_up,
            payload: NotificationPayload.gamificationPayload(
              title: "Level Up!",
              body: "You reached a new level",
              type: NotificationPayload.levelUp,
            ),
          ),
          _payloadTile(
            context,
            title: "Badge Unlocked",
            subtitle: "badge_unlocked",
            icon: Icons.emoji_events,
            payload: NotificationPayload.gamificationPayload(
              title: "Badge Unlocked",
              body: "You unlocked a new badge",
              type: NotificationPayload.badgeUnlocked,
            ),
          ),

          const SizedBox(height: 8),

          _sectionHeader("Admin / System"),
          _payloadTile(
            context,
            title: "Admin Announcement",
            subtitle: "admin_announcement",
            icon: Icons.campaign,
            payload: NotificationPayload.systemPayload(
              title: "Announcement",
              body: "University-wide announcement",
              type: NotificationPayload.adminAnnouncement,
            ),
          ),
          _payloadTile(
            context,
            title: "Profile Reminder",
            subtitle: "profile_completion_reminder",
            icon: Icons.info,
            payload: NotificationPayload.systemPayload(
              title: "Complete Your Profile",
              body: "Finish setting up your profile",
              type: NotificationPayload.profileCompletionReminder,
            ),
          ),
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
        onTap: () {
          _showPayloadDialog(context, payload);
        },
      ),
    );
  }

  void _showPayloadDialog(
      BuildContext context,
      Map<String, dynamic> payload,
      ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Notification Payload"),
          content: SingleChildScrollView(
            child: Text(payload.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}