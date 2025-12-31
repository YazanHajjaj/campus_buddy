import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroup {
  final String id;
  final String title;
  final String course;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final Timestamp createdAt;

  // 🆕 Scheduling (optional)
  final Timestamp? nextSessionAt;
  final String? sessionLocation;
  final String? sessionNote;

  StudyGroup({
    required this.id,
    required this.title,
    required this.course,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
    this.nextSessionAt,
    this.sessionLocation,
    this.sessionNote,
  });

  factory StudyGroup.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return StudyGroup(
      id: doc.id,
      title: data['title'] ?? '',
      course: data['course'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),

      // 🆕 Optional scheduling fields
      nextSessionAt: data['nextSessionAt'],
      sessionLocation: data['sessionLocation'],
      sessionNote: data['sessionNote'],
    );
  }

  /// Used when creating/updating study groups
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'course': course,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': createdAt,

      //  Scheduling (only written if not null)
      if (nextSessionAt != null) 'nextSessionAt': nextSessionAt,
      if (sessionLocation != null) 'sessionLocation': sessionLocation,
      if (sessionNote != null) 'sessionNote': sessionNote,
    };
  }
}