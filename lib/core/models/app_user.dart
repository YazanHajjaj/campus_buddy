import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore-backed application user profile.
class AppUser {
  final String uid;
  final String? email;
  final String role; // e.g. student, mentor, admin
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastLogin;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.isAnonymous,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Serializes this user profile for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  /// Deserializes a Firestore document into an AppUser instance.
  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    final createdAtRaw = data['createdAt'];
    final lastLoginRaw = data['lastLogin'];

    return AppUser(
      uid: documentId,
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'student',
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
      lastLogin: lastLoginRaw is Timestamp
          ? lastLoginRaw.toDate()
          : DateTime.now(),
    );
  }
}
