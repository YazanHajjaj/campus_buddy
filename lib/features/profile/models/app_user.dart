import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;

  final String? name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? department;
  final String? section;
  final String? studentId;
  final String? year;
  final String? profileImageUrl;

  final double? gpa;
  final int? credits;

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

  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    if (data == null) {
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

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return value as DateTime?;
  }
}