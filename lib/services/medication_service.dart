import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationService {
  final FirebaseFirestore firestore;

  MedicationService({required this.firestore});

  Stream<List<Map<String, dynamic>>> getMedications() {
    return firestore.collection('medications').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? '',
          'dose': data['dose'] ?? '',
          'duration': data['duration'] ?? '',
          'imagePath': data['imagePath'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> addMedication(Map<String, dynamic> medicationData) async {
    await firestore.collection('medications').add(medicationData);
  }

  Future<void> updateMedication(
      String docId, Map<String, dynamic> updatedData) async {
    await firestore.collection('medications').doc(docId).update(updatedData);
  }

  Future<void> deleteMedication(String docId) async {
    await firestore.collection('medications').doc(docId).delete();
  }
}
