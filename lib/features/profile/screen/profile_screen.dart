import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/profile_firestore_service.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(); // auth owner
    final profileService = ProfileFirestoreService(); // concrete impl

    final uid = authService.currentUser?.uid;

    // safety guard
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        // TODO: add edit button
      ),
      body: StreamBuilder<AppUser?>(
        stream: profileService.watchUserProfile(uid), // live updates
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final user = snapshot.data;

          // empty / missing doc
          if (user == null) {
            return const Center(child: Text('No profile data'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: profile image
                Text(
                  user.name ?? 'No name',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),

                // email (read-only)
                Text(user.email ?? 'No email'),
                const SizedBox(height: 16),

                // TODO: dropdown later
                Text(user.department ?? 'No department'),
                const SizedBox(height: 8),

                // TODO: multiline edit
                Text(user.bio ?? 'No bio'),
              ],
            ),
          );
        },
      ),
    );
  }
}
