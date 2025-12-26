import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'firestore_user_service.dart';
import '../models/auth_user.dart';

/// Authentication wrapper around FirebaseAuth with Firestore user sync.
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  /// Stream of raw FirebaseAuth user objects.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of AuthUser profiles synced with Firestore.
  Stream<AuthUser?> get authUserChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _userService.upsertUserFromFirebaseUser(user);
    });
  }

  /// Currently signed-in Firebase user.
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // AUTH METHODS
  // ---------------------------------------------------------------------------

  /// Signs in anonymously and ensures a Firestore user exists.
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        await _userService.upsertUserFromFirebaseUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('signInAnonymously error: ${e.code} – ${e.message}');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Convenience alias for guest login used by the UI.
  Future<User?> signInAsGuest() => signInAnonymously();

  /// Email/password sign-in.
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _userService.upsertUserFromFirebaseUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint(
        'signInWithEmailAndPassword error: ${e.code} – ${e.message}',
      );
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Creates an account with email/password and syncs Firestore.
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _userService.upsertUserFromFirebaseUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint(
        'registerWithEmailAndPassword error: ${e.code} – ${e.message}',
      );
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Google sign-in (web + mobile) and Firestore sync.
  Future<User?> signInWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        // Web: use popup with GoogleAuthProvider
        final googleProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Android/iOS: use google_sign_in plugin
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null; // user cancelled

        final googleAuth = await googleUser.authentication;

        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(oauthCredential);
      }

      final user = credential.user;
      if (user != null) {
        await _userService.upsertUserFromFirebaseUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('signInWithGoogle error: ${e.code} – ${e.message}');
      debugPrint(stack.toString());
      rethrow;
    } catch (e, stack) {
      debugPrint('signInWithGoogle unknown error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  // ----- helpers used for Apple Sign-in -----

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Apple sign-in (iOS/macOS only) and Firestore sync.
  Future<User?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final credential =
          await _auth.signInWithCredential(oauthCredential);

      final user = credential.user;
      if (user != null) {
        await _userService.upsertUserFromFirebaseUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('signInWithApple error: ${e.code} – ${e.message}');
      debugPrint(stack.toString());
      rethrow;
    } catch (e, stack) {
      debugPrint('signInWithApple unknown error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Signs out the current Firebase user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Loads the Firestore AuthUser for the current Firebase user.
  Future<AuthUser?> getCurrentAuthUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _userService.getUserById(user.uid);
  }
}
