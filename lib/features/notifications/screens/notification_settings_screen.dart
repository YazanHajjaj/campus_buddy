import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _docId = 'main';

  late final String uid;
  late final DocumentReference<Map<String, dynamic>> docRef;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    uid = user.uid;
    docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notification_settings')
        .doc(_docId);

    _ensureDefaults();
  }

  Future<void> _ensureDefaults() async {
    final snap = await docRef.get();

    if (!snap.exists) {
      await docRef.set({
        'events': true,
        'mentorship': true,
        'studyGroups': false,
        'gamification': true,
        'admin': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF2E4BC6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data()!;
          bool enabled(String key) => data[key] == true;

          final enabledCount =
              data.entries.where((e) => e.value == true).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoBox(enabledCount: enabledCount),
              const SizedBox(height: 16),

              _ToggleTile(
                icon: Icons.event,
                title: 'Event Notifications',
                subtitle:
                'Get notified about upcoming events and RSVP reminders',
                value: enabled('events'),
                onChanged: (v) => _update('events', v),
              ),

              _ToggleTile(
                icon: Icons.people,
                title: 'Mentorship Notifications',
                subtitle:
                'Receive updates about mentorship requests and messages',
                value: enabled('mentorship'),
                onChanged: (v) => _update('mentorship', v),
              ),

              _ToggleTile(
                icon: Icons.menu_book,
                title: 'Study Group Notifications',
                subtitle:
                'Stay updated on study group activities and invitations',
                value: enabled('studyGroups'),
                onChanged: (v) => _update('studyGroups', v),
              ),

              _ToggleTile(
                icon: Icons.emoji_events,
                title: 'Gamification Notifications',
                subtitle:
                'Get alerts for achievements, badges, and leaderboard updates',
                value: enabled('gamification'),
                onChanged: (v) => _update('gamification', v),
              ),

              _ToggleTile(
                icon: Icons.campaign,
                title: 'Admin Announcements',
                subtitle:
                'Important updates and announcements from administration',
                value: enabled('admin'),
                onChanged: (v) => _update('admin', v),
              ),

              const SizedBox(height: 24),

              const _StaticCard(
                title: 'About Push Notifications',
                body:
                'Push notifications are sent even when the app is closed. '
                    'Make sure notifications are enabled in your device settings.',
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _update(String key, bool value) {
    return docRef.set(
      {
        key: value,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

/* ───────── UI ───────── */

class _InfoBox extends StatelessWidget {
  final int enabledCount;
  const _InfoBox({required this.enabledCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$enabledCount notification types enabled\n'
                  'You can change these settings at any time',
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _StaticCard extends StatelessWidget {
  final String title;
  final String body;
  const _StaticCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}