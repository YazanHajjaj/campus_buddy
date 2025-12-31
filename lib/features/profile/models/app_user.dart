import 'package:cloud_firestore/cloud_firestore.dart';

/// Core user domain model.
/// Represents a user document from Firestore.
///
/// Notes:
/// - Nullable fields reflect optional profile completion
/// - This model is UI-agnostic and service-agnostic
/// - Timestamp conversion is handled safely
class AppUser {
  /// Firestore document ID
  final String uid;

  // ───────── BASIC PROFILE ─────────
  final String? name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? department;
  final String? section;
  final String? studentId;
  final String? year;
  final String? profileImageUrl;

  // ───────── ACADEMIC INFO ─────────
  final double? gpa;
  final int? credits;

  // ───────── METADATA ─────────
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.bio,
    this.department,
    this.section,
    this.studentId,
    this.year,
    this.profileImageUrl,
    this.gpa,
    this.credits,
    this.createdAt,
    this.updatedAt,
  });

  /// Build AppUser from Firestore data.
  ///
  /// - Safe against missing documents
  /// - Timestamp → DateTime handled internally
  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    if (data == null) {
      // Allows creating a lightweight user object
      // even if Firestore document does not exist yet
      return AppUser(uid: uid);
    }

    return AppUser(
      uid: uid,
      name: data['name'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      bio: data['bio'] as String?,
      department: data['department'] as String?,
      section: data['section'] as String?,
      studentId: data['studentId'] as String?,
      year: data['year'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      gpa: (data['gpa'] as num?)?.toDouble(),
      credits: data['credits'] as int?,
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  /// Convert model to Firestore-compatible map.
  ///
  /// - Used only by services
  /// - Timestamps can be overwritten by serverTimestamp if needed
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'department': department,
      'section': section,
      'studentId': studentId,
      'year': year,
      'profileImageUrl': profileImageUrl,
      'gpa': gpa,
      'credits': credits,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Converts Firestore Timestamp or DateTime into DateTime.
  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return value as DateTime?;
  }
}