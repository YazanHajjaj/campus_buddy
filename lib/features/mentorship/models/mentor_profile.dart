import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a mentor-facing profile stored in `mentor_profiles/{mentorId}`
/// This is intentionally separate from `users/{uid}` to avoid coupling
/// mentorship-specific data with auth / general profile data.
class MentorProfile {

  final String id;

  /// References users/{uid}
  /// Used for permission checks and joins with user profile data
  final String userId;

  /// Display name shown in mentor lists and details
  final String name;
  final String? photoUrl;
  final String? bio;
  final String? department;
  final String? faculty;
  final List<String> expertise;
  final bool isActive;
  final double ratingAvg;
  final int ratingCount;
  final int activeMenteesCount;

  /// Audit timestamps
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const MentorProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.photoUrl,
    required this.bio,
    required this.department,
    required this.faculty,
    required this.expertise,
    required this.isActive,
    required this.ratingAvg,
    required this.ratingCount,
    required this.activeMenteesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Used mainly by services when partially updating mentor data
  MentorProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? photoUrl,
    String? bio,
    String? department,
    String? faculty,
    List<String>? expertise,
    bool? isActive,
    double? ratingAvg,
    int? ratingCount,
    int? activeMenteesCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return MentorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      department: department ?? this.department,
      faculty: faculty ?? this.faculty,
      expertise: expertise ?? this.expertise,
      isActive: isActive ?? this.isActive,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      activeMenteesCount: activeMenteesCount ?? this.activeMenteesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Firestore serialization
  /// `id` is excluded because it's the document key
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'department': department,
      'faculty': faculty,
      'expertise': expertise,
      'isActive': isActive,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'activeMenteesCount': activeMenteesCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Safe Firestore deserialization
  /// Handles missing / legacy fields without crashing
  static MentorProfile fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MentorProfile(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      department: data['department'] as String?,
      faculty: data['faculty'] as String?,
      expertise: List<String>.from((data['expertise'] ?? const []) as List),
      isActive: (data['isActive'] ?? true) as bool,
      ratingAvg: _asDouble(data['ratingAvg'], fallback: 0.0),
      ratingCount: (data['ratingCount'] ?? 0) as int,
      activeMenteesCount: (data['activeMenteesCount'] ?? 0) as int,
      createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      updatedAt: (data['updatedAt'] ?? Timestamp.now()) as Timestamp,
    );
  }

  /// Firestore sometimes stores numbers as int or double depending on writes
  /// This avoids runtime cast errors when reading aggregates
  static double _asDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return fallback;
  }
}
