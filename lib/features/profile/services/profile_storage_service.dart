import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import 'profile_service.dart';

/// Handles uploading and deleting user profile images.
/// This works together with ProfileFirestoreService for metadata updates.
class ProfileStorageService implements ProfileService {
  final _users = FirebaseFirestore.instance.collection('users');
  final _storage = FirebaseStorage.instance;

  ProfileStorageService();

  /// Path where profile image is stored.
  String _imagePath(String uid) {
    return 'users/$uid/profile.jpg';
  }

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child(_imagePath(uid));

      // upload file
      await ref.putFile(imageFile);

      // get public download url
      final url = await ref.getDownloadURL();

      // write url to Firestore
      await _users.doc(uid).set(
        {
          'profileImageUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return url;
    } catch (e) {
      print('uploadProfileImage error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProfileImage(String uid) async {
    try {
      final ref = _storage.ref().child(_imagePath(uid));

      // If there is no file, delete will throw, so we try/catch silently.
      await ref.delete().catchError((_) {});

      // remove url from Firestore
      await _users.doc(uid).set(
        {
          'profileImageUrl': null,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('deleteProfileImage error: $e');
      rethrow;
    }
  }

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
    return _users.doc(uid).snapshots().map((snap) {
      return AppUser.fromMap(uid, snap.data());
    });
  }
}
