import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a study group with its own member list and chat
/// Stored in `study_groups/{groupId}`
class StudyGroup {
  /// Firestore document ID
  final String id;

  final String title;

  final String? description;

  /// users/{uid} of the creator
  /// Used for ownership and moderation checks
  final String createdBy;
  final List<String> tags;
  final int memberCount;
  final int maxMembers;
  final bool isPrivate;

  /// Audit timestamps
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const StudyGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.tags,
    required this.memberCount,
    required this.maxMembers,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore serialization
  /// `id` is excluded since it's the document key
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'tags': tags,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'isPrivate': isPrivate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Safe Firestore deserialization
  /// Applies defaults to keep legacy or partial data readable
  static StudyGroup fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    return StudyGroup(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: data['description'] as String?,
      createdBy: (data['createdBy'] ?? '') as String,
      tags: List<String>.from((data['tags'] ?? const []) as List),
      memberCount: (data['memberCount'] ?? 0) as int,
      maxMembers: (data['maxMembers'] ?? 10) as int,
      isPrivate: (data['isPrivate'] ?? false) as bool,
      createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
      updatedAt: (data['updatedAt'] ?? Timestamp.now()) as Timestamp,
    );
  }
}
