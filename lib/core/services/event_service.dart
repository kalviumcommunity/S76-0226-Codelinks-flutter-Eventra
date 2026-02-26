import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Singleton service to manage events.
/// Uses Firestore when available, falls back to in-memory storage.
class EventService extends ChangeNotifier {
  EventService._();
  static final EventService instance = EventService._();

  static const _collection = 'events';
  final _uuid = const Uuid();

  // Local in-memory store (used when Firestore is unavailable)
  final List<Event> _localEvents = [
    Event(
      id: '1',
      title: 'Tech Symposium 2026',
      description:
          'Annual technology symposium featuring guest speakers from top tech firms.',
      date: DateTime.now().add(const Duration(days: 5)),
      venue: 'Main Auditorium',
      registeredCount: 45,
      maxParticipants: 100,
      schedule: [
        '9:00 AM - Keynote',
        '11:00 AM - Panel Discussion',
        '2:00 PM - Workshops',
      ],
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1771645903251-eba25bb877c2?w=500&auto=format&fit=crop&q=60',
    ),
    Event(
      id: '2',
      title: 'Cultural Night',
      description:
          'A night of music, dance, and cultural performances by our students.',
      date: DateTime.now().add(const Duration(days: 12)),
      venue: 'Open Air Theatre',
      registeredCount: 120,
      maxParticipants: 200,
      schedule: [
        '6:00 PM - Folk Dance',
        '7:30 PM - Music Band',
        '9:00 PM - Dinner',
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=2070&auto=format&fit=crop',
    ),
    Event(
      id: '3',
      title: 'Tech Night',
      description:
          'An evening of tech demos, hackathon showcases, and networking.',
      date: DateTime.now().add(const Duration(days: 20)),
      venue: 'Innovation Hub',
      registeredCount: 60,
      maxParticipants: 150,
      schedule: [
        '5:00 PM - Demo Booths',
        '7:00 PM - Hackathon Showcase',
        '8:30 PM - Networking Dinner',
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1733241317703-7f51a0aa90cf?q=80&w=1170&auto=format&fit=crop',
    ),
  ];

  // ----- Firestore helpers -----

  CollectionReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection(_collection);

  Map<String, dynamic> _eventToMap(Event e) => {
        'title': e.title,
        'description': e.description,
        'date': Timestamp.fromDate(e.date),
        'venue': e.venue,
        'registeredCount': e.registeredCount,
        'maxParticipants': e.maxParticipants,
        'schedule': e.schedule,
        'imageUrl': e.imageUrl,
        'registeredUsers': e.registeredUsers,
      };

  Event _eventFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Event(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
      venue: d['venue'] ?? '',
      registeredCount: d['registeredCount'] ?? 0,
      maxParticipants: d['maxParticipants'] ?? 0,
      schedule: List<String>.from(d['schedule'] ?? []),
      imageUrl: d['imageUrl'] ?? '',
      registeredUsers: List<String>.from(d['registeredUsers'] ?? []),
    );
  }

  // ----- Public API -----

  /// Get all events. Returns a Firestore stream or the local list.
  Stream<List<Event>> getEventsStream() {
    if (isFirebaseInitialized) {
      return _ref.orderBy('date').snapshots().map(
            (snap) => snap.docs.map(_eventFromDoc).toList(),
          );
    }
    return Stream.value(List.unmodifiable(_localEvents));
  }

  /// Get all events once.
  Future<List<Event>> getEvents() async {
    if (isFirebaseInitialized) {
      final snap = await _ref.orderBy('date').get();
      return snap.docs.map(_eventFromDoc).toList();
    }
    return List.unmodifiable(_localEvents);
  }

  /// Add a new event.
  Future<void> addEvent(Event event) async {
    if (isFirebaseInitialized) {
      await _ref.doc(event.id).set(_eventToMap(event));
    } else {
      _localEvents.add(event);
      notifyListeners();
    }
  }

  /// Create an event from form fields.
  Future<Event> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String venue,
    required int maxParticipants,
    required List<String> schedule,
    String imageUrl = '',
  }) async {
    final event = Event(
      id: _uuid.v4(),
      title: title,
      description: description,
      date: date,
      venue: venue,
      registeredCount: 0,
      maxParticipants: maxParticipants,
      schedule: schedule,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://images.unsplash.com/photo-1540575861501-7ad058138a31?q=80&w=2070&auto=format&fit=crop',
    );
    await addEvent(event);
    return event;
  }

  /// Delete an event.
  Future<void> deleteEvent(String id) async {
    if (isFirebaseInitialized) {
      await _ref.doc(id).delete();
    } else {
      _localEvents.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }

  /// Register a user for an event.
  Future<void> registerForEvent(String eventId, String userId) async {
    if (isFirebaseInitialized) {
      await _ref.doc(eventId).update({
        'registeredUsers': FieldValue.arrayUnion([userId]),
        'registeredCount': FieldValue.increment(1),
      });
    } else {
      final idx = _localEvents.indexWhere((e) => e.id == eventId);
      if (idx != -1) {
        final e = _localEvents[idx];
        if (!e.registeredUsers.contains(userId)) {
          _localEvents[idx] = Event(
            id: e.id,
            title: e.title,
            description: e.description,
            date: e.date,
            venue: e.venue,
            registeredCount: e.registeredCount + 1,
            maxParticipants: e.maxParticipants,
            schedule: e.schedule,
            imageUrl: e.imageUrl,
            registeredUsers: [...e.registeredUsers, userId],
          );
          notifyListeners();
        }
      }
    }
  }

  /// Unregister a user from an event.
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    if (isFirebaseInitialized) {
      await _ref.doc(eventId).update({
        'registeredUsers': FieldValue.arrayRemove([userId]),
        'registeredCount': FieldValue.increment(-1),
      });
    } else {
      final idx = _localEvents.indexWhere((e) => e.id == eventId);
      if (idx != -1) {
        final e = _localEvents[idx];
        if (e.registeredUsers.contains(userId)) {
          _localEvents[idx] = Event(
            id: e.id,
            title: e.title,
            description: e.description,
            date: e.date,
            venue: e.venue,
            registeredCount: e.registeredCount - 1,
            maxParticipants: e.maxParticipants,
            schedule: e.schedule,
            imageUrl: e.imageUrl,
            registeredUsers:
                e.registeredUsers.where((u) => u != userId).toList(),
          );
          notifyListeners();
        }
      }
    }
  }

  /// Total registrations across all local events.
  int get totalRegistrations =>
      _localEvents.fold(0, (sum, e) => sum + e.registeredCount);

  /// Number of upcoming events.
  int get upcomingCount =>
      _localEvents.where((e) => e.date.isAfter(DateTime.now())).length;

  int get totalEvents => _localEvents.length;
}
