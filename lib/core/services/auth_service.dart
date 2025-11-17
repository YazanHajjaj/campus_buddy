import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_user_service.dart';
import '../models/app_user.dart';

/// Wraps FirebaseAuth and synchronizes user profiles with Firestore.
class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  /// Raw Firebase authStateChanges stream (emits Firebase [User?] objects).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Higher-level stream that emits [AppUser] instances.
  ///
  /// For each Firebase auth state change:
  /// - If user is null → emits null.
  /// - If user is not null → upserts the Firestore profile and emits [AppUser].
  Stream<AppUser?> get appUserChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _userService.upsertUserFromFirebaseUser(user);
    });
  }

  /// Currently signed-in Firebase user (or null if signed out).
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // SIGN IN / REGISTER METHODS
  // Each method:
  //  1) Performs Firebase Auth.
  //  2) Upserts user profile in Firestore via FirestoreUserService.
  // ---------------------------------------------------------------------------

  /// Anonymous sign-in.
  ///
  /// Returns the signed-in [User] on success, or rethrows [FirebaseAuthException]
  /// on failure.
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

  /// Email + password sign-in.
  ///
  /// Returns the signed-in [User] on success, or rethrows [FirebaseAuthException]
  /// on failure.
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

  /// Email + password registration (account creation).
  ///
  /// Returns the created [User] on success, or rethrows [FirebaseAuthException]
  /// on failure.
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

  /// Returns the Firestore-backed [AppUser] for the current Firebase user.
  ///
  /// Returns null if no user is signed in or if the profile does not exist.
  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _userService.getUserById(user.uid);
  }
}
