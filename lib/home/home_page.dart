import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_repository.dart';
import 'package:campus_buddy/features/notifications/screens/notifications_screen.dart';
import 'package:campus_buddy/features/notifications/services/notification_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return _HomeView(
          uid: uid,
          name: data['name'] ?? 'Student',
          role: data['role'] ?? 'student',
        );
      },
    );
  }
}

/* ───────────────────────────────────────────── */

class _HomeView extends StatelessWidget {
  final String uid;
  final String name;
  final String role;

  const _HomeView({
    required this.uid,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final homeRepo = HomeRepository();
    final notifRepo = NotificationRepository();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2446C8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Home'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: notifRepo.unreadForUser(uid),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Stack(
                children: [
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
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* ───── WELCOME ───── */
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Welcome, $name 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              /* ───── BANNER ───── */
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/study_material.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              /* ───── SECTIONS ───── */
              const Text(
                'Sections',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              _CardShell(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: StreamBuilder<QuerySnapshot>(
                  stream: homeRepo.departments(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    return SizedBox(
                      height: 120, // ✅ FIXED OVERFLOW
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data!.docs.map((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          return _SectionItem(
                            imageAsset: d['iconAsset'],
                            title: d['code'],
                            onTap: () {
                              debugPrint('Tapped department ${d['code']}');
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              /* ───── COURSES ───── */
              const Text(
                'Most searched courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: homeRepo.mostSearchedCourses(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  return SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data!.docs.map((doc) {
                        final c = doc.data() as Map<String, dynamic>;
                        return _CourseCard(
                          imageAsset: c['imageAsset'],
                          title: c['title'],
                          description: c['description'],
                          onTap: () {
                            debugPrint('Tapped course ${c['title']}');
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────────────────────────── */

class _SectionItem extends StatelessWidget {
  final String imageAsset;
  final String title;
  final VoidCallback onTap;

  const _SectionItem({
    required this.imageAsset,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imageAsset,
                height: 56,
                width: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CourseCard({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageAsset,
                height: 140,
                width: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────────────────────────── */

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}