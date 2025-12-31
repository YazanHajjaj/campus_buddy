import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/auth_user.dart';

/// Firestore operations for AuthUser records.
class FirestoreUserService {
  FirestoreUserService._internal();
  static final FirestoreUserService _instance =
  FirestoreUserService._internal();
  factory FirestoreUserService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  /// Returns the AuthUser for the given uid.
  Future<AuthUser?> getUserById(String uid) async {
    final doc = await _usersRef.doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AuthUser.fromMap(doc.data()!, doc.id);
  }

  /// Saves or updates the provided AuthUser.
  Future<void> saveUser(AuthUser user) async {
    await _usersRef.doc(user.uid).set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }

  /// Updates last login timestamp.
  Future<void> updateLastLogin(String uid, DateTime timestamp) async {
    await _usersRef.doc(uid).set(
      {'lastLogin': Timestamp.fromDate(timestamp)},
      SetOptions(merge: true),
    );
  }

  /// Updates a single onboarding checklist flag.
  Future<void> updateOnboardingFlag(
      String uid,
      String key,
      bool value,
      ) async {
    await _usersRef.doc(uid).set(
      {
        'onboardingChecklist': {
          key: value,
        }
      },
      SetOptions(merge: true),
    );
  }

  /// Ensures gamification-related fields exist.
  Future<void> ensureGamificationFields(String uid) async {
    await _usersRef.doc(uid).set(
      {
        'xp': 0,
        'earnedBadges': <String>[],
      },
      SetOptions(merge: true),
    );
  }

  /// Creates or updates an AuthUser from FirebaseAuth.
  Future<AuthUser> upsertUserFromFirebaseUser(
      fb_auth.User firebaseUser,
      ) async {
    final now = DateTime.now();
    final docRef = _usersRef.doc(firebaseUser.uid);
    final existing = await docRef.get();

    if (!existing.exists || existing.data() == null) {
      final newUser = AuthUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        role: 'student',
        isAnonymous: firebaseUser.isAnonymous,
        createdAt: now,
        lastLogin: now,
      );

      await docRef.set({
        ...newUser.toMap(),
        'xp': 0,
        'earnedBadges': <String>[],
      });

      return newUser;
    }

    await docRef.set(
      {
        'lastLogin': Timestamp.fromDate(now),
        'isAnonymous': firebaseUser.isAnonymous,
        'email': firebaseUser.email,
      },
      SetOptions(merge: true),
    );

    await ensureGamificationFields(firebaseUser.uid);

    final updated = await docRef.get();
    return AuthUser.fromMap(updated.data()!, updated.id);
  }
}