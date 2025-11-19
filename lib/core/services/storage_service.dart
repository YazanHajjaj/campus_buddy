import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage wrapper for file uploads and deletions.
class StorageService {
  /// Instance bound to the project's storage bucket.
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: "gs://campusbuddy-sentinel.firebasestorage.app",
  );

  FirebaseStorage get storage => _storage;

  /// Uploads a file to the given storage path.
  /// Returns the download URL on success, or null on failure.
  Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    final exists = file.existsSync();
    print("[StorageService] Upload start: path=$path, exists=$exists");

    if (!exists) {
      print("[StorageService] Upload aborted: file not found on disk.");
      return null;
    }

    try {
      final ref = _storage.ref(path);
      print("[StorageService] Storage ref: ${ref.fullPath}");

      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        print(
          "[StorageService] Upload state=${event.state} "
              "bytes=${event.bytesTransferred}/${event.totalBytes}",
        );
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final url = await snapshot.ref.getDownloadURL();
        print("[StorageService] Upload completed. URL=$url");
        return url;
      } else {
        print("[StorageService] Upload finished with state: ${snapshot.state}");
        return null;
      }
    } on FirebaseException catch (e) {
      print("[StorageService] Firebase error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("[StorageService] Unexpected error: $e");
      return null;
    }
  }

  /// Deletes a file at the given storage path.
  /// Returns true if deletion succeeds, otherwise false.
  Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
      print("[StorageService] File deleted: $path");
      return true;
    } on FirebaseException catch (e) {
      print("[StorageService] Firebase delete error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      print("[StorageService] Unexpected delete error: $e");
      return false;
    }
  }
}
