import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Core
import 'core/auth/sign_in_screen.dart';
import 'core/services/auth_service.dart';

// Debug
import 'debug/developer_tools_screen.dart';

// Admin
import 'features/admin/screens/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  runApp(const CampusBuddyApp());
}

class CampusBuddyApp extends StatelessWidget {
  const CampusBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) return const HomeScreen();
        return const SignInScreen();
      },
    );
  }
}

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
                  MaterialPageRoute(builder: (_) => const DeveloperToolsScreen()),
                );
              } else if (value == "logout") {
                await AuthService().signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "dev_tools", child: Text("Developer Tools")),
              PopupMenuItem(value: "logout", child: Text("Sign Out")),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 60),
            const SizedBox(height: 16),
            Text("Signed In", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text("UID:\n${user?.uid ?? "-"}", textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              "Anonymous User: ${user?.isAnonymous ?? false}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("Open Admin Dashboard"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
