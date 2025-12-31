import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore diagnostics used by the Firebase health check.
class FirestoreTestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('health_check');

  Future<bool> testWrite() async {
    try {
      await _ref.doc('test_doc').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'write_test_ok',
      });
      return true;
    } catch (e) {
      debugPrint('[FirestoreTestService] write failed');
      return false;
    }
  }

  Future<bool> testRead() async {
    try {
      final doc = await _ref.doc('test_doc').get();
      return doc.exists;
    } catch (e) {
      debugPrint('[FirestoreTestService] read failed');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTestDocument() async {
    try {
      final doc = await _ref.doc('test_doc').get();
      return doc.data();
    } catch (e) {
      debugPrint('[FirestoreTestService] fetch failed');
      return null;
    }
  }
}