import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserService {
  final FirebaseFirestore _db;

  AdminUserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Fetch users for admin inspection (read only)
  Future<List<Map<String, dynamic>>> getUsers() async {
    final snap = await _users
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      return {
        'uid': d.id,
        'email': data['email'],
        'role': data['role'] ?? 'student',
        'xp': data['xp'] ?? 0,
        'createdAt': data['createdAt'],
      };
    }).toList();
  }
}