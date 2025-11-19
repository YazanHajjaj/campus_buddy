import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// Debug/testing screens
import 'debug/firebase_health_check.dart';
import 'debug/test_resource_backend.dart';

// Auth + App Core
import 'core/auth/sign_in_screen.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Anonymous fallback ONLY if no user signed in
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }

  runApp(const CampusBuddyApp());
}

class CampusBuddyApp extends StatelessWidget {
  const CampusBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Buddy',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const AuthGate(), // Entry point decided by authentication
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ---------------------------------------------------------
/// AuthGate — Chooses which screen to show:
/// - Signed in → HomeScreen
/// - Not signed in → SignInScreen
/// ---------------------------------------------------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User authenticated → go to HomeScreen
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // No user → go to SignInScreen
        return const SignInScreen();
      },
    );
  }
}

/// ---------------------------------------------------------
/// HomeScreen — Basic signed-in screen
/// Shows user's UID and anonymous status.
/// ---------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Buddy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 60),
            const SizedBox(height: 16),
            Text(
              "Signed In",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "UID:\n${user?.uid}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Anonymous User: ${user?.isAnonymous}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Optional debug navigation
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResourceBackendTestScreen(),
                  ),
                );
              },
              child: const Text("Open Resource Backend Test"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FirebaseHealthCheckScreen(),
                  ),
                );
              },
              child: const Text("Open Firebase Health Check"),
            ),
          ],
        ),
      ),
    );
  }
}
