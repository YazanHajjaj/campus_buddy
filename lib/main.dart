import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Debug / testing (still available elsewhere if you use it)
import 'debug/developer_tools_screen.dart';

// Authentication
import 'core/auth/sign_in_screen.dart';
import 'core/services/auth_service.dart';

// Profile (used from other screens, not from main)
import 'features/profile/edit_profile_screen.dart';

// Events (Phase 4 – used from other screens, not from main)
import 'features/events/screens/event_create_screen.dart';

// Splash
import 'splash_screen.dart';

// New Home UI
import 'home/home_page.dart';
import 'package:campus_buddy/shell/app_shell.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Do NOT sign in here. Auth flow is controlled by AuthGate.
  runApp(const CampusBuddyApp());
}

class CampusBuddyApp extends StatelessWidget {
  const CampusBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const SplashScreen(), // First screen -> then should go to AuthGate
    );
  }
}

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
          // ✅ use AppShell here (no const)
          return AppShell();
        }

        // not logged in
        return const SignInScreen();
      },
    );
  }
}
