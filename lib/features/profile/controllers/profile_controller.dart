import 'dart:io';

import '../models/app_user.dart';
import '../services/profile_service.dart';

/// A simple controller for profile actions.
/// The UI will use this instead of calling service methods directly.
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

  /// Update fields like name, bio, department, etc.
  Future<void> updateProfile(
      String uid, {
        String? name,
        String? bio,
        String? department,
      }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (department != null) data['department'] = department;

    if (data.isEmpty) return; // nothing to update

    await service.updateUserProfile(uid, data);
  }

  /// Upload or replace profile image.
  Future<String> uploadImage(String uid, File file) {
    return service.uploadProfileImage(uid, file);
  }

  /// Remove user avatar.
  Future<void> deleteImage(String uid) {
    return service.deleteProfileImage(uid);
  }
}
