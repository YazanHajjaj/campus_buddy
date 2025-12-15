import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore-backed application user profile.
class AuthUser {
  final String uid;
  final String? email;
  final String role;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastLogin;

  AuthUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.isAnonymous,
    required this.createdAt,
    required this.lastLogin,
  });

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

  factory AuthUser.fromMap(Map<String, dynamic> data, String documentId) {
    final createdAtRaw = data['createdAt'];
    final lastLoginRaw = data['lastLogin'];

    return AuthUser(
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
