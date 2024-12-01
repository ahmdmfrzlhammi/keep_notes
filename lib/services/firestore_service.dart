import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan semua notes berdasarkan user
  Stream<QuerySnapshot> read() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true) // pastikan ada indeks untuk 'timestamp'
        .snapshots();
  }

  // Menambahkan note baru
  Future<void> createNote({
    required String title,
    required String content,
    required List<String> tags,
    required String imageUrl,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      await _db.collection('notes').add({
        'title': title,
        'content': content,
        'tags': tags,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(), // Timestamp yang valid
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating note: $e");
    }
  }

  // Mengupdate note
  Future<void> updateNote({
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

  // Mendapatkan semua events berdasarkan user
  Stream<QuerySnapshot> getCalendarEvents() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      print("User not logged in");
      return Stream.empty(); // return an empty stream if no user is logged in
    }

    return _db.collection('calendar_events')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots();
  }

  // Menambahkan event ke Firestore
  Future<void> addEvent({
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