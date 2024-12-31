import 'package:cloud_firestore/cloud_firestore.dart';

class SleepService {
  final FirebaseFirestore firestore;

  SleepService({required this.firestore});

  Stream<List<Map<String, dynamic>>> getSleepRecords() {
    return firestore.collection('sleep').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'date': data['date'] ?? '',
          'hours': data['hours'] ?? '',
          'note': data['note'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> addSleepRecord(Map<String, dynamic> sleepData) async {
    await firestore.collection('sleep').add(sleepData);
  }

  Future<void> updateSleepRecord(
      String docId, Map<String, dynamic> updatedData) async {
    await firestore.collection('sleep').doc(docId).update(updatedData);
  }

  Future<void> deleteSleepRecord(String docId) async {
    await firestore.collection('sleep').doc(docId).delete();
  }
}
