import 'package:cloud_firestore/cloud_firestore.dart';

/// Application-level representation of a user profile stored in Firestore.
/// This model abstracts away FirebaseAuth.User and keeps only the fields
/// required by the app (role, timestamps, anonymous state, etc.).
class AppUser {
  final String uid;
  final String? email;
  final String role; // e.g. "student", "mentor", "admin"
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

  /// Converts the user profile into a Firestore-ready map.
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

  /// Constructs an [AppUser] from Firestore data.
  ///
  /// Any missing fields are replaced with safe defaults.
  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    final createdAtRaw = data['createdAt'];
    final lastLoginRaw = data['lastLogin'];

    return AppUser(
      uid: documentId,
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'student',
      isAnonymous: data['isAnonymous'] as bool? ?? false,

      // Fallbacks ensure model remains safe even if timestamps are missing.
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),

      lastLogin: lastLoginRaw is Timestamp
          ? lastLoginRaw.toDate()
          : DateTime.now(),
    );
  }
}
