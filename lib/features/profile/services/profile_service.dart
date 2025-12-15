import 'dart:io';

import '../models/app_user.dart';

/// Base contract for profile operations.
abstract class ProfileService {
  /// Fetch profile info once.
  Future<AppUser?> getUserProfile(String uid);

  /// Listen for live profile updates.
  Stream<AppUser?> watchUserProfile(String uid);

  /// Update provided profile fields only.
  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> data,
      );

  /// Upload a new profile image.
  Future<String> uploadProfileImage(String uid, File imageFile);

  /// Delete current profile image.
  Future<void> deleteProfileImage(String uid);
}
