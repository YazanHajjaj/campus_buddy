import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_buddy/core/models/auth_user.dart';
import 'package:campus_buddy/core/services/auth_service.dart';

import 'package:campus_buddy/features/profile/controllers/profile_controller.dart';
import 'package:campus_buddy/features/profile/models/app_user.dart';
import 'package:campus_buddy/features/profile/services/profile_storage_service.dart';

import 'package:campus_buddy/features/analytics/services/analytics_service.dart';
import 'package:campus_buddy/features/analytics/models/student_analytics.dart';

import 'package:campus_buddy/features/gamification/services/firestore_leaderboard_service.dart';
import 'package:campus_buddy/features/gamification/models/leaderboard_entry.dart';
import 'package:campus_buddy/features/gamification/screens/leaderboard_screen.dart';

import 'package:campus_buddy/features/notifications/screens/notifications_screen.dart';
import 'package:campus_buddy/features/bookmarks/screens/bookmark_list_screen.dart';
import 'package:campus_buddy/features/study_groups/screens/study_groups_list_screen.dart';
import 'package:campus_buddy/features/productivity/checklist_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/* ───────────────────────────────────────────── */

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final _analyticsService = AnalyticsService();
  final _leaderboardService = FirestoreLeaderboardService();

  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController =
        ProfileController(service: ProfileStorageService());
  }

  Future<_HomeData?> _load() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;

    final authUser = await _authService.getCurrentAuthUser();
    final profile = await _profileController.getProfile(uid);
    final analytics = await _analyticsService.getStudentAnalytics(uid);
    final leaderboardEntry =
    await _leaderboardService.getUserEntry(uid);

    return _HomeData(
      uid: uid,
      authUser: authUser,
      profile: profile,
      analytics: analytics,
      leaderboardEntry: leaderboardEntry,
    );
  }

  String _welcomeName(AppUser? profile, AuthUser? authUser) {
    if (profile?.name?.isNotEmpty == true) {
      return profile!.name!.split(' ').first;
    }
    if (authUser?.email != null) {
      return authUser!.email!.split('@').first;
    }
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usage_logs')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, _) {
        return FutureBuilder<_HomeData?>(
          future: _load(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data!;
            final name = _welcomeName(data.profile, data.authUser);

            return _DashboardView(
              welcomeName: name,
              uid: data.uid,
              analytics: data.analytics,
              leaderboardEntry: data.leaderboardEntry,
            );
          },
        );
      },
    );
  }
}

/* ───────────────────────────────────────────── */

class _DashboardView extends StatelessWidget {
  final String welcomeName;
  final String uid;
  final StudentAnalytics analytics;
  final LeaderboardEntry? leaderboardEntry;

  const _DashboardView({
    required this.welcomeName,
    required this.uid,
    required this.analytics,
    required this.leaderboardEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Welcome, $welcomeName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookmarkListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track your academic progress',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            _OnboardingCard(uid: uid),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.school,
                    label: 'Mentorship Sessions',
                    value: '${analytics.mentorshipSessionsCount}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available,
                    label: 'Events Joined',
                    value: '${analytics.eventsRsvpCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book,
                    label: 'Resources Uploaded',
                    value: '${analytics.resourcesUploadedCount}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    label: 'Rank',
                    value: leaderboardEntry == null
                        ? '—'
                        : '#${leaderboardEntry!.rank}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Groups',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join or create groups to study together',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.group),
                      label: const Text('Open Study Groups'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const StudyGroupsListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────────────────────────── */

class _OnboardingCard extends StatelessWidget {
  final String uid;
  const _OnboardingCard({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final checklist =
        Map<String, bool>.from(data?['onboardingChecklist'] ?? {});
        final completed = checklist.values.where((v) => v).length;

        if (completed >= 5) return const SizedBox.shrink();

        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Getting Started'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: completed / 5),
              const SizedBox(height: 8),
              Text('$completed / 5 completed'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChecklistScreen(),
                    ),
                  );
                },
                child: const Text('Open Checklist'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ───────────────────────────────────────────── */

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
            theme.colorScheme.primary.withOpacity(0.12),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(label),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/* ───────────────────────────────────────────── */

class _HomeData {
  final String uid;
  final AuthUser? authUser;
  final AppUser? profile;
  final StudentAnalytics analytics;
  final LeaderboardEntry? leaderboardEntry;

  _HomeData({
    required this.uid,
    required this.authUser,
    required this.profile,
    required this.analytics,
    required this.leaderboardEntry,
  });
}