import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepository {
  final _firestore = FirebaseFirestore.instance;

  // Banner config
  Future<String?> getBanner(String role) async {
    final doc =
    await _firestore.collection('home_config').doc('main').get();
    if (!doc.exists) return null;

    return role == 'mentor'
        ? doc['mentorBanner']
        : doc['studentBanner'];
  }

  // Departments
  Stream<QuerySnapshot> departments() {
    return _firestore
        .collection('departments')
        .orderBy('order')
        .snapshots();
  }

  // Most searched courses
  Stream<QuerySnapshot> mostSearchedCourses() {
    return _firestore
        .collection('courses')
        .orderBy('searchCount', descending: true)
        .limit(10)
        .snapshots();
  }
}