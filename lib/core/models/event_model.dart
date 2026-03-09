import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String venue;
  final int registeredCount;
  final int maxParticipants;
  final List<String> schedule;
  final String imageUrl;
  final String organizer;
  final String createdBy;
  final DateTime createdAt;
  final List<String> registeredUsers;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
    required this.registeredCount,
    required this.maxParticipants,
    required this.schedule,
    required this.imageUrl,
    required this.organizer,
    required this.createdBy,
    required this.createdAt,
    this.registeredUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'venue': venue,
      'registeredCount': registeredCount,
      'maxParticipants': maxParticipants,
      'schedule': schedule,
      'imageUrl': imageUrl,
      'organizer': organizer,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      venue: map['venue'] ?? '',
      registeredCount: map['registeredCount'] ?? 0,
      maxParticipants: map['maxParticipants'] ?? 0,
      schedule: List<String>.from(map['schedule'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      organizer: map['organizer'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
