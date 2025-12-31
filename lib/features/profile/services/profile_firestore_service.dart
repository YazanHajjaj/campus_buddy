import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'profile_service.dart';
import '../../../core/services/firestore_user_service.dart';

/// Firestore-backed implementation of [ProfileService].
class ProfileFirestoreService implements ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppUser.fromMap(doc.id, doc.data());
  }

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

      return AppUser.fromMap(doc.id, doc.data());
    });
  }

  @override
  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await _firestore.collection('users').doc(uid).update(data);

    // Onboarding checklist: profile completed
    // Fire-and-forget (do not block profile save)
    _userService.updateOnboardingFlag(
      uid,
      'profileCompleted',
      true,
    );
  }

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProfileImage(String uid) async {
    // TODO
  }
}