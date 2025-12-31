import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a mentor profile stored in:
/// mentor_profiles/{authUid}
///
/// FINAL RULES (DO NOT CHANGE):
/// - documentId == FirebaseAuth.uid
/// - userId == FirebaseAuth.uid (duplicated for clarity / joins)
/// - mentorship_requests.mentorId == FirebaseAuth.uid
///
/// This model is intentionally:
/// - Immutable
/// - Firestore-safe
/// - Backward compatible with older documents
class MentorProfile {
  /* ───────────────── IDENTIFIERS ───────────────── */

  /// Firestore document ID (mentor_profiles/{uid})
  final String id;

  /// Firebase Auth UID (duplicated for clarity)
  final String userId;

  /* ───────────────── DISPLAY INFO ───────────────── */

  final String name;
  final String? photoUrl;
  final String? bio;

  /* ───────────────── ACADEMIC INFO ───────────────── */

  final String? department;
  final String? faculty;

  /* ───────────────── EXPERTISE ───────────────── */

  /// List of mentor expertise tags (e.g. "Flutter", "AI", "Math")
  final List<String> expertise;

  /* ───────────────── STATUS ───────────────── */

  /// Whether mentor is accepting new requests
  final bool isActive;

  /* ───────────────── RATINGS ───────────────── */

  /// Average rating (0.0 – 5.0)
  /// Stored explicitly to avoid recalculation
  final double ratingAvg;

  /// Total number of submitted ratings
  final int ratingCount;

  /* ───────────────── LOAD TRACKING ───────────────── */

  /// Currently active mentees
  final int activeMenteesCount;

  /// Maximum allowed concurrent mentees
  final int maxActiveMentees;

  /* ───────────────── AUDIT ───────────────── */

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
    required this.maxActiveMentees,
    required this.createdAt,
    required this.updatedAt,
  });

  /* ───────────────── COPY ───────────────── */

  /// Creates a modified copy of the profile.
  /// Used when updating Firestore documents.
  MentorProfile copyWith({
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
    int? maxActiveMentees,
    Timestamp? updatedAt,
  }) {
    return MentorProfile(
      id: id,
      userId: userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      department: department ?? this.department,
      faculty: faculty ?? this.faculty,
      expertise: expertise ?? this.expertise,
      isActive: isActive ?? this.isActive,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      activeMenteesCount:
      activeMenteesCount ?? this.activeMenteesCount,
      maxActiveMentees:
      maxActiveMentees ?? this.maxActiveMentees,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /* ───────────────── FIRESTORE ───────────────── */

  /// Converts this model to Firestore-compatible map.
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
      'maxActiveMentees': maxActiveMentees,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Builds a MentorProfile from Firestore document.
  ///
  /// Defensive defaults ensure:
  /// - Old documents still work
  /// - Missing fields do not crash the app
  static MentorProfile fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return MentorProfile(
      id: doc.id,
      userId: (data['userId'] ?? doc.id) as String,
      name: (data['name'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      department: data['department'] as String?,
      faculty: data['faculty'] as String?,
      expertise: List<String>.from(data['expertise'] ?? const []),
      isActive: (data['isActive'] ?? true) as bool,

      // Ratings default to 0 for mentors without reviews
      ratingAvg: _asDouble(data['ratingAvg']),
      ratingCount: (data['ratingCount'] ?? 0) as int,

      activeMenteesCount:
      (data['activeMenteesCount'] ?? 0) as int,
      maxActiveMentees:
      (data['maxActiveMentees'] ?? 0) as int,

      createdAt:
      (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      updatedAt:
      (data['updatedAt'] ?? Timestamp.now()) as Timestamp,
    );
  }

  /* ───────────────── COMPUTED ───────────────── */

  /// Whether the mentor has reached capacity.
  bool get isFull {
    if (maxActiveMentees <= 0) return true;
    return activeMenteesCount >= maxActiveMentees;
  }

  /* ───────────────── HELPERS ───────────────── */

  /// Safely converts Firestore numeric values to double.
  static double _asDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return fallback;
  }
}