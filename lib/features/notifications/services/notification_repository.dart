import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col =>
      _firestore.collection('notifications');

  Stream<QuerySnapshot> unreadForUser(String uid) {
    return _col
        .where('uid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot> allForUser(String uid) {
    return _col
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String id) async {
    await _col.doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final unread = await _col
        .where('uid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}