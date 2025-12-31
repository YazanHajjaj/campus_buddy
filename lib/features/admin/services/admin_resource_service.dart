import 'package:cloud_firestore/cloud_firestore.dart';

class AdminResourceService {
  final FirebaseFirestore _db;

  AdminResourceService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _resources =>
      _db.collection('resources');

  /// Fetch uploaded resources (read only)
  Future<List<Map<String, dynamic>>> getResources() async {
    final snap = await _resources
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'title': data['title'],
        'uploader': data['uploaderDisplayName'],
        'category': data['category'],
        'isPublic': data['isPublic'],
        'createdAt': data['createdAt'],
      };
    }).toList();
  }
}