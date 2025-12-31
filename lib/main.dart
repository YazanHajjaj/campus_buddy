import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';

// Accessibility
import 'core/state/accessibility_controller.dart';

// Localization
import 'core/localization/app_localizations.dart';

// Splash & Auth
import 'splash_screen.dart';
import 'core/auth/sign_in_screen.dart';
import 'core/services/auth_service.dart';

// App shell
import 'shell/app_shell.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // ✅ REQUIRED


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AccessibilityController(),
      child: const CampusBuddyApp(),
    ),
  );
}

/* ───────────────── APP ROOT ───────────────── */

class CampusBuddyApp extends StatelessWidget {
  const CampusBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityController>(
      builder: (context, accessibility, _) {
        if (!accessibility.loaded) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Campus Buddy',

          // ✅ THIS IS THE KEY FIX (DYNAMIC LOCALE)
          locale: Locale(accessibility.languageCode),

          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
          ],

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: accessibility.highContrast
              ? _highContrastTheme
              : _defaultCampusTheme,

          home: const SplashScreen(),
        );
      },
    );
  }
}

/* ───────────────── THEMES ───────────────── */

final ThemeData _defaultCampusTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2446C8),
    brightness: Brightness.light,
  ),

  scaffoldBackgroundColor: const Color(0xFFF3F4F6),
  cardColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2446C8),
    foregroundColor: Colors.white,
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    titleMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w700,
    ),
  ),
);

final ThemeData _highContrastTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  colorScheme: const ColorScheme.highContrastLight(),

  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w800,
    ),
  ),

  dividerColor: Colors.black,
);

/* ───────────────── AUTH GATE ───────────────── */

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

        if (!snapshot.hasData) {
          return const SignInScreen();
        }

        return const AppShell();
      },
    );
  }
}