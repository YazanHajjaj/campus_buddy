import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Central wrapper for Firebase Storage operations.
class StorageService {
  /// Explicit instance bound to the Campus Buddy storage bucket.
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: "gs://campusbuddy-sentinel.firebasestorage.app",
  );

  FirebaseStorage get storage => _storage;

  /// Uploads [file] to the given [path] in Firebase Storage.
  ///
  /// Returns the public download URL on success, or `null` if the upload fails.
  Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    final exists = file.existsSync();
    print("📁 [StorageService] Starting upload to: $path");
    print("📁 [StorageService] File exists: $exists | ${file.path}");

    if (!exists) {
      print("🔥 [StorageService] Aborting upload: file does not exist on disk.");
      return null;
    }

    try {
      // Create a storage reference for the target path.
      final ref = _storage.ref(path);
      print("☁️ [StorageService] Got ref: ${ref.fullPath}");

      final uploadTask = ref.putFile(file);

      // Log basic progress to the console for debugging.
      uploadTask.snapshotEvents.listen((event) {
        final transferred = event.bytesTransferred;
        final total = event.totalBytes;
        print(
          "⬆️ [StorageService] State: ${event.state} | bytes: $transferred/$total",
        );
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final url = await snapshot.ref.getDownloadURL();
        print("✅ [StorageService] Upload completed. Download URL: $url");
        return url;
      } else {
        print(
          "⚠️ [StorageService] Upload finished with non-success state: ${snapshot.state}",
        );
        return null;
      }
    } on FirebaseException catch (e) {
      print(
        "🔥 [StorageService] FirebaseException during upload: ${e.code} - ${e.message}",
      );
      return null;
    } catch (e) {
      print("🔥 [StorageService] Unexpected upload error: $e");
      return null;
    }
  }

  /// Deletes the object at the given [path] from Firebase Storage.
  ///
  /// Returns `true` on successful deletion, `false` if an error occurs.
  Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
      print("🗑️ [StorageService] Deleted file at: $path");
      return true;
    } on FirebaseException catch (e) {
      print(
        "🔥 [StorageService] FirebaseException during delete: ${e.code} - ${e.message}",
      );
      return false;
    } catch (e) {
      print("🔥 [StorageService] Unexpected delete error: $e");
      return false;
    }
  }
}
