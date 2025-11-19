import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// Debug/testing
import 'debug/developer_tools_screen.dart';

// Authentication
import 'core/auth/sign_in_screen.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Anonymous fallback sign-in for development
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
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Selects initial screen based on FirebaseAuth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const SignInScreen();
      },
    );
  }
}

/// Home screen with user info and access to Developer Tools.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Buddy"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "dev_tools") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeveloperToolsScreen(),
                  ),
                );
              } else if (value == "logout") {
                await AuthService().signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "dev_tools",
                child: Text("Developer Tools"),
              ),
              PopupMenuItem(
                value: "logout",
                child: Text("Sign Out"),
              ),
            ],
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
          ],
        ),
      ),
    );
  }
}
