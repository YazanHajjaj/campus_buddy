import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Firebase Storage helper for uploads and deletions.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    if (!file.existsSync()) {
      debugPrint('[StorageService] file not found');
      return null;
    }

    try {
      final ref = _storage.ref(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }

      return null;
    } on FirebaseException catch (e) {
      debugPrint('[StorageService] upload failed: ${e.code}');
      return null;
    } catch (_) {
      debugPrint('[StorageService] upload failed');
      return null;
    }
  }

  Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[StorageService] delete failed: ${e.code}');
      return false;
    } catch (_) {
      debugPrint('[StorageService] delete failed');
      return false;
    }
  }
}