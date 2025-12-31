import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campus_buddy/core/localization/app_localizations.dart';

import 'mentor_profile_screen.dart';
import 'edit_mentor_profile_screen.dart';

class MentorMyProfileScreen extends StatelessWidget {
  const MentorMyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final t = AppLocalizations.of(context);

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(t.t('error.unauthorized'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.t('profile.myProfile'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditMentorProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: MentorProfileScreen(
        mentorId: uid,      // your mentor doc id (best = auth uid)
        allowEdit: true,    // ✅ ONLY here
      ),
    );
  }
}