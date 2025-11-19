import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple Firestore diagnostics used by the Firebase health check screen.
class FirestoreTestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('health_check');

  /// Writes a diagnostic document for testing Firestore write access.
  Future<bool> testWrite() async {
    try {
      await _ref.doc('test_doc').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'write_test_ok',
      });
      return true;
    } catch (e) {
      print('[FirestoreTestService] Write error: $e');
      return false;
    }
  }

  /// Reads the diagnostic document to verify read access.
  Future<bool> testRead() async {
    try {
      final doc = await _ref.doc('test_doc').get();
      return doc.exists;
    } catch (e) {
      print('[FirestoreTestService] Read error: $e');
      return false;
    }
  }

  /// Retrieves the stored diagnostic document for display in the UI.
  Future<Map<String, dynamic>?> getTestDocument() async {
    try {
      final doc = await _ref.doc('test_doc').get();
      return doc.data();
    } catch (e) {
      print('[FirestoreTestService] GetDocument error: $e');
      return null;
    }
  }
}
