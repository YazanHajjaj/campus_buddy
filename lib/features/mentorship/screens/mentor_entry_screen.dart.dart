import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'create_mentor_profile_screen.dart';
import 'mentor_mentorship_home_screen.dart';

class MentorEntryScreen extends StatelessWidget {
  const MentorEntryScreen({super.key});

  static const _primaryBlue = Color(0xFF2446C8);

  Future<bool> _mentorProfileExists(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('mentor_profiles')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return FutureBuilder<bool>(
      future: _mentorProfileExists(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasProfile = snapshot.data ?? false;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Mentor',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: hasProfile
                ? _ExistingMentorView()
                : _CreateMentorView(),
          ),
        );
      },
    );
  }
}

/* ───────────────── EXISTING MENTOR ───────────────── */

class _ExistingMentorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.school,
          size: 72,
          color: Color(0xFF2446C8),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome back, Mentor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your mentorship requests and active students',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2446C8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MentorMentorshipHomeScreen(),
                ),
              );
            },
            child: const Text(
              'Go to Mentor Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

/* ───────────────── CREATE MENTOR ───────────────── */

class _CreateMentorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person_add_alt_1,
          size: 72,
          color: Color(0xFF2446C8),
        ),
        const SizedBox(height: 20),
        const Text(
          'Become a Mentor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Create your mentor profile to start helping students',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2446C8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateMentorProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Create Mentor Profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}