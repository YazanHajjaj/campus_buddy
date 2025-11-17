import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility service for performing Firestore read/write diagnostics.
/// Used by FirebaseHealthCheckScreen for system verification.
class FirestoreTestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('health_check');

  /// Writes a simple diagnostic document for health testing.
  ///
  /// Returns true on success, false if an exception occurs.
  Future<bool> testWrite() async {
    try {
      await _ref.doc('test_doc').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'write_test_ok',
      });
      return true;
    } catch (e) {
      print('🔥 [FirestoreTestService] WRITE error: $e');
      return false;
    }
  }

  /// Reads the previously written test document.
  ///
  /// Returns true if the document exists, false otherwise.
  Future<bool> testRead() async {
    try {
      final doc = await _ref.doc('test_doc').get();
      return doc.exists;
    } catch (e) {
      print('🔥 [FirestoreTestService] READ error: $e');
      return false;
    }
  }

  /// Returns the stored diagnostic document for debugging.
  Future<Map<String, dynamic>?> getTestDocument() async {
    try {
      final doc = await _ref.doc('test_doc').get();
      return doc.data();
    } catch (e) {
      print('🔥 [FirestoreTestService] GET DOCUMENT error: $e');
      return null;
    }
  }
}
