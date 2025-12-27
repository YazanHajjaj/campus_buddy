import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import 'profile_service.dart';

/// Handles profile image storage and Firestore profile access.
/// Storage ONLY uploads/deletes files.
/// Firestore writes are handled by ProfileController.
class ProfileStorageService implements ProfileService {
  final _users = FirebaseFirestore.instance.collection('users');
  final _storage = FirebaseStorage.instance;

  ProfileStorageService();

  /// Path where profile image is stored.
  String _imagePath(String uid) {
    return 'users/$uid/profile.jpg';
  }

  // =========================
  // IMAGE STORAGE
  // =========================

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child(_imagePath(uid));

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }

  @override
  Future<void> deleteProfileImage(String uid) async {
    final ref = _storage.ref().child(_imagePath(uid));

    // Deleting a non-existing file throws → ignore safely
    try {
      await ref.delete();
    } catch (_) {}
  }

  // =========================
  // PROFILE DATA
  // =========================

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return AppUser.fromMap(uid, doc.data());
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<AppUser?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map(
          (snap) => AppUser.fromMap(uid, snap.data()),
    );
  }
}