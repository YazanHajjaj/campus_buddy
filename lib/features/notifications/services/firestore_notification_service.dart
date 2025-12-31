import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  Future<void> createNotification({
    required String uid,
    required Map<String, dynamic> payload,
  }) async {
    await _collection.add({
      'uid': uid,
      'title': payload['title'],
      'body': payload['body'],
      'type': payload['type'],
      'referenceId': payload['referenceId'],
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}