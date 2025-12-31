import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroupSession {
  final String id;
  final String groupId;

  final String title;
  final String location;

  final Timestamp date;        // Day of the session
  final String startTime;      // "14:00"
  final String endTime;        // "16:00"

  final String createdBy;
  final Timestamp createdAt;

  StudyGroupSession({
    required this.id,
    required this.groupId,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.createdAt,

  });

  factory StudyGroupSession.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      String groupId,
      ) {
    final data = doc.data()!;
    return StudyGroupSession(
      id: doc.id,
      groupId: groupId,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}