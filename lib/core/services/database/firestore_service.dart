import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
import '../../models/announcement_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Functions ---

  /// Creates a new user document in the 'users' collection.
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Retrieves a user document by its ID.
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // --- Event Functions ---

  /// Creates a new event document in the 'events' collection.
  Future<void> createEvent(EventModel event) async {
    try {
      final docRef = _db.collection('events').doc();
      final eventWithId = EventModel(
        id: docRef.id,
        title: event.title,
        description: event.description,
        date: event.date,
        venue: event.venue,
        registeredCount: event.registeredCount,
        maxParticipants: event.maxParticipants,
        schedule: event.schedule,
        imageUrl: event.imageUrl,
        organizer: event.organizer,
        createdBy: event.createdBy,
        createdAt: event.createdAt,
      );
      await docRef.set(eventWithId.toMap());
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  /// Returns a stream of all events, ordered by date.
  Stream<List<EventModel>> getAllEvents() {
    return _db
        .collection('events')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Retrieves a single event by its ID.
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      if (doc.exists && doc.data() != null) {
        return EventModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  /// Deletes an event by its ID.
  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  // --- Announcement Functions ---

  /// Creates a new announcement document in the 'announcements' collection.
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    try {
      final docRef = _db.collection('announcements').doc();
      final announcementWithId = AnnouncementModel(
        id: docRef.id,
        title: announcement.title,
        message: announcement.message,
        createdAt: announcement.createdAt,
      );
      await docRef.set(announcementWithId.toMap());
    } catch (e) {
      throw Exception('Error creating announcement: $e');
    }
  }

  /// Returns a stream of announcements, ordered by creation date.
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _db
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromMap(doc.data()))
          .toList();
    });
  }

  // --- Registration Functions ---

  /// Registers a user for a specific event.
  Future<void> registerForEvent(String userId, String eventId) async {
    try {
      final registrationId = '${userId}_$eventId';
      final registrationData = {
        'id': registrationId,
        'userId': userId,
        'eventId': eventId,
        'registeredAt': FieldValue.serverTimestamp(),
      };

      await _db.runTransaction((transaction) async {
        final eventRef = _db.collection('events').doc(eventId);
        final registrationRef =
            _db.collection('registrations').doc(registrationId);

        final eventSnapshot = await transaction.get(eventRef);
        if (!eventSnapshot.exists) {
          throw Exception('Event does not exist');
        }

        final registrationSnapshot = await transaction.get(registrationRef);
        if (registrationSnapshot.exists) {
          throw Exception('User already registered for this event');
        }

        final currentCount = eventSnapshot.data()?['registeredCount'] ?? 0;
        final maxCount = eventSnapshot.data()?['maxParticipants'] ?? 0;

        if (maxCount > 0 && currentCount >= maxCount) {
          throw Exception('Event is full');
        }

        transaction.set(registrationRef, registrationData);
        transaction.update(eventRef, {'registeredCount': currentCount + 1});
      });
    } catch (e) {
      throw Exception('Error registering for event: $e');
    }
  }

  /// Returns a stream of users registered for a specific event.
  Stream<List<UserModel>> getEventAttendees(String eventId) {
    return _db
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .asyncMap((snapshot) async {
      final userIds =
          snapshot.docs.map((doc) => doc.data()['userId'] as String).toList();

      if (userIds.isEmpty) return [];

      // Fetch user details for each registered ID
      // Note: Firestore 'in' query is limited to 10 items.
      // For more, you'd need multiple queries or separate fetches.
      final userSnapshots = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.take(10).toList())
          .get();

      return userSnapshots.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }
}
