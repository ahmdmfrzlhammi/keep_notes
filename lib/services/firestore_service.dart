import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream untuk membaca catatan berdasarkan user ID dan status arsip
  Stream read({bool isArchived = false, String? selectedTag}) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    var query = FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: isArchived)
        .orderBy('timestamp', descending: true);

    if (selectedTag != null && selectedTag.isNotEmpty) {
      query = query.where('tags', arrayContains: selectedTag);
    }

    return query.snapshots();
  }

  /// Stream untuk mendapatkan semua tags yang tersedia
  Stream<List<String>> getAllTags() {
    String? userId = _auth.currentUser?.uid;
    return _db
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      Set<String> uniqueTags = {};
      for (var doc in snapshot.docs) {
        List<dynamic> tags = doc.data()['tags'] ?? [];
        uniqueTags.addAll(tags.map((tag) => tag.toString()));
      }
      return uniqueTags.toList()..sort();
    });
  }

  /// Membuat catatan baru dengan tags
  Future createNote({
    required String title,
    required String content,
    required List<String> tags,
    required String imageUrl,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _db.collection('notes').add({
        'title': title,
        'content': content,
        'tags': tags,
        'userId': userId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isArchived': false,
      });
    } catch (e) {
      print("Error creating note: $e");
    }
  }

  /// Memperbarui catatan yang ada
  Future updateNote({
    required String noteId,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    try {
      await _db.collection('notes').doc(noteId).update({
        'title': title,
        'content': content,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating note: $e");
    }
  }

  /// Mengarsipkan catatan
  Future archiveNote({
    required String noteId,
  }) async {
    try {
      await _db.collection('notes').doc(noteId).update({
        'isArchived': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error archiving note: $e");
    }
  }

  /// Membatalkan arsip catatan
  Future unarchiveNote({
    required String noteId,
  }) async {
    try {
      await _db.collection('notes').doc(noteId).update({
        'isArchived': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error unarchiving note: $e");
    }
  }

  /// Stream untuk membaca event kalender
  Stream getCalendarEvents() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      print("User not logged in");
      return Stream.empty();
    }

    return _db
        .collection('calendar_events')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots();
  }

  /// Menambahkan event ke kalender
  Future addEvent({
    required String event,
    String? note,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _db.collection('calendar_events').add({
          'userId': userId,
          'event': event,
          'note': note ?? '',
          'date': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      print("Error adding event: $e");
    }
  }
}