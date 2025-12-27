import 'dart:io';

import '../models/app_user.dart';
import '../services/profile_service.dart';

/// Controller for profile-related actions.
/// UI talks to this layer only.
class ProfileController {
  final ProfileService service;

  ProfileController({required this.service});

  /// Listen to real-time profile updates.
  Stream<AppUser?> watchProfile(String uid) {
    return service.watchUserProfile(uid);
  }

  /// Fetch user data once.
  Future<AppUser?> getProfile(String uid) {
    return service.getUserProfile(uid);
  }

  /// Update profile fields.
  /// Any update here MUST reflect in live listeners.
  Future<void> updateProfile(
      String uid, {
        String? name,
        String? email,
        String? phone,
        String? bio,
        String? department,
        String? section,
        String? studentId,
        String? year,
      }) async {
    final data = <String, dynamic>{};

    void putIfValid(String key, String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      data[key] = trimmed;
    }

    putIfValid('name', name);
    putIfValid('email', email);
    putIfValid('phone', phone);
    putIfValid('bio', bio);
    putIfValid('department', department);
    putIfValid('section', section);
    putIfValid('studentId', studentId);
    putIfValid('year', year);

    if (data.isEmpty) return;

    data['updatedAt'] = DateTime.now();

    await service.updateUserProfile(uid, data);
  }

  /// Upload profile image AND save its URL to Firestore.
  /// This ensures Live Listen updates immediately.
  Future<String?> uploadImage(String uid, File file) async {
    final imageUrl = await service.uploadProfileImage(uid, file);

    if (imageUrl == null) return null;

    await service.updateUserProfile(uid, {
      'profileImageUrl': imageUrl,
      'updatedAt': DateTime.now(),
    });

    return imageUrl;
  }

  /// Delete profile image from storage AND clear Firestore field.
  Future<void> deleteImage(String uid) async {
    await service.deleteProfileImage(uid);

    await service.updateUserProfile(uid, {
      'profileImageUrl': null,
      'updatedAt': DateTime.now(),
    });
  }
}