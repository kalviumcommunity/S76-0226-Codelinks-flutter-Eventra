import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/announcement_model.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Singleton service to manage announcements.
/// Uses Firestore when available, falls back to in-memory storage.
class AnnouncementService extends ChangeNotifier {
  AnnouncementService._();
  static final AnnouncementService instance = AnnouncementService._();

  static const _collection = 'announcements';
  final _uuid = const Uuid();

  // Local in-memory store
  final List<Announcement> _localAnnouncements = [
    Announcement(
      id: '1',
      title: 'New Workshop Added!',
      message:
          'A Flutter Advanced workshop has been added to the Tech Symposium list.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Announcement(
      id: '2',
      title: 'Venue Change',
      message:
          'The Cultural Night will now be held at the Main Auditorium instead of the OAT.',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ----- Firestore helpers -----

  CollectionReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection(_collection);

  Map<String, dynamic> _toMap(Announcement a) => {
        'title': a.title,
        'message': a.message,
        'date': Timestamp.fromDate(a.date),
      };

  Announcement _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Announcement(
      id: doc.id,
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
    );
  }

  // ----- Public API -----

  /// Stream of all announcements.
  Stream<List<Announcement>> getAnnouncementsStream() {
    if (isFirebaseInitialized) {
      return _ref.orderBy('date', descending: true).snapshots().map(
            (snap) => snap.docs.map(_fromDoc).toList(),
          );
    }
    return Stream.value(List.unmodifiable(_localAnnouncements));
  }

  /// Get all announcements once.
  Future<List<Announcement>> getAnnouncements() async {
    if (isFirebaseInitialized) {
      final snap = await _ref.orderBy('date', descending: true).get();
      return snap.docs.map(_fromDoc).toList();
    }
    return List.unmodifiable(_localAnnouncements);
  }

  /// Post a new announcement.
  Future<void> addAnnouncement({
    required String title,
    required String message,
  }) async {
    final announcement = Announcement(
      id: _uuid.v4(),
      title: title,
      message: message,
      date: DateTime.now(),
    );

    if (isFirebaseInitialized) {
      await _ref.doc(announcement.id).set(_toMap(announcement));
    } else {
      _localAnnouncements.insert(0, announcement);
      notifyListeners();
    }
  }

  /// Delete an announcement.
  Future<void> deleteAnnouncement(String id) async {
    if (isFirebaseInitialized) {
      await _ref.doc(id).delete();
    } else {
      _localAnnouncements.removeWhere((a) => a.id == id);
      notifyListeners();
    }
  }

  int get totalCount => _localAnnouncements.length;
}
