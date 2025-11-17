import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/app_user.dart';

/// Handles all Firestore operations related to user profiles.
class FirestoreUserService {
  FirestoreUserService._internal();

  static final FirestoreUserService _instance =
  FirestoreUserService._internal();

  factory FirestoreUserService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  /// Returns the user profile for the given [uid], or null if no document exists.
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _usersRef.doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppUser.fromMap(doc.data()!, doc.id);
  }

  /// Creates or updates a user document with the full [AppUser] payload.
  Future<void> saveUser(AppUser user) async {
    await _usersRef.doc(user.uid).set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }

  /// Updates only the lastLogin timestamp for the given [uid].
  Future<void> updateLastLogin(String uid, DateTime timestamp) async {
    await _usersRef.doc(uid).set(
      {
        'lastLogin': Timestamp.fromDate(timestamp),
      },
      SetOptions(merge: true),
    );
  }

  /// Upserts a user profile based on the provided Firebase [firebaseUser].
  ///
  /// - If the user document does not exist, a new one is created with:
  ///   role = "student" by default.
  /// - If it exists, lastLogin, isAnonymous and email fields are updated.
  /// Returns the resulting [AppUser] representation.
  Future<AppUser> upsertUserFromFirebaseUser(
      fb_auth.User firebaseUser,
      ) async {
    final now = DateTime.now();
    final docRef = _usersRef.doc(firebaseUser.uid);
    final existingDoc = await docRef.get();

    if (!existingDoc.exists || existingDoc.data() == null) {
      // First-time login: create a new profile.
      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        role: 'student', // default role for now
        isAnonymous: firebaseUser.isAnonymous,
        createdAt: now,
        lastLogin: now,
      );

      await docRef.set(newUser.toMap());
      return newUser;
    } else {
      // Existing profile: update login metadata.
      await docRef.set(
        {
          'lastLogin': Timestamp.fromDate(now),
          'isAnonymous': firebaseUser.isAnonymous,
          'email': firebaseUser.email,
        },
        SetOptions(merge: true),
      );

      // Read the updated document to return a fresh AppUser snapshot.
      final updatedDoc = await docRef.get();
      return AppUser.fromMap(updatedDoc.data()!, updatedDoc.id);
    }
  }
}
