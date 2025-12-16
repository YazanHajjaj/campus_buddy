import 'package:cloud_firestore/cloud_firestore.dart';

// core event model
// used by list, details, calendar, rsvp
class Event {
  // firestore doc id
  final String id;

  // main info
  final String title;
  final String description;
  final String location;

  // date used for calendar grouping
  // start/end used for time range
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  // admin uid
  final String createdBy;

  // online vs physical event
  final bool isOnline;

  // optional banner image
  final String? imageUrl;

  // used for filtering
  final List<String> tags;

  // capacity control
  final int capacity;
  final int attendeesCount;

  // metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.isOnline,
    required this.imageUrl,
    required this.tags,
    required this.capacity,
    required this.attendeesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // firestore -> model
  factory Event.fromMap(String id, Map<String, dynamic> data) {
    DateTime _dt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Event(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      date: _dt(data['date']),
      startTime: _dt(data['startTime']),
      endTime: _dt(data['endTime']),
      createdBy: (data['createdBy'] ?? '').toString(),
      isOnline: data['isOnline'] == true,
      imageUrl: data['imageUrl']?.toString(),
      tags: List<String>.from(data['tags'] ?? const []),
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      attendeesCount:
      (data['attendeesCount'] as num?)?.toInt() ?? 0,
      createdAt: _dt(data['createdAt']),
      updatedAt: _dt(data['updatedAt']),
    );
  }

  // model -> firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'createdBy': createdBy,
      'isOnline': isOnline,
      'imageUrl': imageUrl,
      'tags': tags,
      'capacity': capacity,
      'attendeesCount': attendeesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
