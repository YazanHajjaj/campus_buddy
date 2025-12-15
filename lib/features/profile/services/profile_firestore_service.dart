import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'profile_service.dart';

/// Firestore-backed implementation of [ProfileService].
/// Reads and writes profile data from `users/{uid}`.
class ProfileFirestoreService implements ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch profile info once.
  @override
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    // map -> model
    return AppUser.fromMap(
      doc.id,
      doc.data(),
    );
  }

  /// Listen for live profile updates.
  @override
  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      // map -> model
      return AppUser.fromMap(
        doc.id,
        doc.data(),
      );
    });
  }

  /// Update only provided profile fields.
  @override
  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  /// Upload a new profile image for the user.
  /// Storage wiring will be added later.
  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    // TODO: wire Firebase Storage upload
    throw UnimplementedError();
  }

  /// Delete the user's current profile image.
  /// Storage wiring will be added later.
  @override
  Future<void> deleteProfileImage(String uid) async {
    // TODO: implement image delete
  }
}
