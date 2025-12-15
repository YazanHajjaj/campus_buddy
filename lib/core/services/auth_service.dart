import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
