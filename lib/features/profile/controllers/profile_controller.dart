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
    String? bio,
    String? department,
    String? email,
    String? phone,
    String? section,
    String? year,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (department != null) data['department'] = department;

    // extra fields you may want to store in Firestore
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (section != null) data['section'] = section;
    if (year != null) data['year'] = year;

    if (data.isEmpty) return;

    await service.updateUserProfile(uid, data);
  }

  /// Upload profile image AND save its URL to Firestore.
  /// This ensures Live Listen updates immediately.
  Future<String?> uploadImage(String uid, File file) async {
    final imageUrl = await service.uploadProfileImage(uid, file);

    if (imageUrl == null) return null;

    await service.updateUserProfile(uid, {
      'profileImageUrl': imageUrl,
    });

    return imageUrl;
  }

  /// Delete profile image from storage AND clear Firestore field.
  Future<void> deleteImage(String uid) async {
    await service.deleteProfileImage(uid);

    await service.updateUserProfile(uid, {
      'profileImageUrl': null,
    });
  }
}
