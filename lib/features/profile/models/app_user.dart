import 'package:cloud_firestore/cloud_firestore.dart';

/// Basic user profile data stored in Firestore.
/// Used across profile, mentorship, resource uploads, etc.
class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? bio;
  final String? department;
  final String? profileImageUrl; // avatar photo
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    this.name,
    this.email,
    this.bio,
    this.department,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create object from Firestore map
  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    if (data == null) {
      return AppUser(uid: uid);
    }

    return AppUser(
      uid: uid,
      name: data['name'] as String?,
      email: data['email'] as String?,
      bio: data['bio'] as String?,
      department: data['department'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  /// Convert object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Makes it easier to update selected fields
  AppUser copyWith({
    String? name,
    String? email,
    String? bio,
    String? department,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Quick helper since Firestore stores timestamps
  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return value as DateTime?;
  }
}
