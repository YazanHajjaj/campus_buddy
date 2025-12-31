import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'firestore_user_service.dart';
import '../models/auth_user.dart';

/// Authentication service wrapping FirebaseAuth
/// with Firestore user synchronization.
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  /// Firebase authentication state stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Firestore-backed AuthUser stream.
  Stream<AuthUser?> get authUserChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _userService.upsertUserFromFirebaseUser(user);
    });
  }

  User? get currentUser => _auth.currentUser;

  // ---------------- Authentication ----------------

  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        await _userService.upsertUserFromFirebaseUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('signInAnonymously error: ${e.code}');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Future<User?> signInAsGuest() => signInAnonymously();

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
      debugPrint('signInWithEmailAndPassword error: ${e.code}');
      debugPrint(stack.toString());
      rethrow;
    }
  }

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
      debugPrint('registerWithEmailAndPassword error: ${e.code}');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      throw Exception('Google Sign-In not supported on iOS');
    }

    try {
      UserCredential credential;

      if (kIsWeb) {
        credential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

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
    } catch (e, stack) {
      debugPrint('signInWithGoogle error');
      debugPrint(stack.toString());
      rethrow;
    }
  }

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
    return sha256.convert(bytes).toString();
  }

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
      debugPrint('signInWithApple error: ${e.code}');
      debugPrint(stack.toString());
      rethrow;
    } catch (e, stack) {
      debugPrint('signInWithApple error');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthUser?> getCurrentAuthUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _userService.getUserById(user.uid);
  }
}