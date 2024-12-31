import 'package:cloud_firestore/cloud_firestore.dart';

class NoteService {
  final FirebaseFirestore firestore;

  NoteService({required this.firestore});

  Stream<List<Map<String, dynamic>>> getNotes() {
    return firestore.collection('notes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? '',
          'content': data['content'] ?? '',
          'imagePath': data['imagePath'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> addNote(Map<String, dynamic> noteData) async {
    await firestore.collection('notes').add(noteData);
  }

  Future<void> updateNote(
      String docId, Map<String, dynamic> updatedData) async {
    await firestore.collection('notes').doc(docId).update(updatedData);
  }

  Future<void> deleteNote(String docId) async {
    await firestore.collection('notes').doc(docId).delete();
  }
}
