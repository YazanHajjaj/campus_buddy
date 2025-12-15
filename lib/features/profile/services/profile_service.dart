import '../models/app_user.dart';
import 'dart:io';

/// Basic API for reading and updating user profile information.
/// This is the base contract; the Firestore implementation will handle the real work.
abstract class ProfileService {
  /// Fetch profile info for a user.
  Future<AppUser?> getUserProfile(String uid);

  /// Update simple profile fields (name, bio, department, etc.).
  /// Only updates provided values.
  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> data,
      );

  /// Upload a new profile image for the user.
  /// Returns the download URL after upload.
  Future<String> uploadProfileImage(String uid, File imageFile);

  /// Remove the user's current profile image, if any.
  Future<void> deleteProfileImage(String uid);

  /// Stream for live profile updates.
  Stream<AppUser?> watchUserProfile(String uid);
}
