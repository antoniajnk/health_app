import 'package:cloud_firestore/cloud_firestore.dart';

class HabitService {
  final FirebaseFirestore firestore;

  HabitService({required this.firestore});

  Stream<List<Map<String, dynamic>>> getHabits() {
    return firestore.collection('habits').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? '',
          'frequency': data['frequency'] ?? '',
          'isCompleted': data['isCompleted'] ?? false,
        };
      }).toList();
    });
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    await firestore.collection('habits').add(habitData);
  }

  Future<void> updateHabit(
      String docId, Map<String, dynamic> updatedData) async {
    await firestore.collection('habits').doc(docId).update(updatedData);
  }

  Future<void> deleteHabit(String docId) async {
    await firestore.collection('habits').doc(docId).delete();
  }
}
