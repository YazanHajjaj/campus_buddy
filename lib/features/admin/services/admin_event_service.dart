import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEventService {
  final FirebaseFirestore _db;

  AdminEventService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('events');

  /// Fetch all events (admin view – read only)
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final snap = await _events
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snap.docs
        .map((d) => {
      'id': d.id,
      ...d.data(),
    })
        .toList();
  }
}