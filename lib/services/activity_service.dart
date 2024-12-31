import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore firestore;

  ActivityService({required this.firestore});

  Stream<List<Map<String, dynamic>>> getActivities() {
    return firestore.collection('activities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? '',
          'duration': data['duration'] ?? '',
          'distance': data['distance'] ?? '',
          'imagePath': data['imagePath'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> addActivity(Map<String, dynamic> activityData) async {
    await firestore.collection('activities').add(activityData);
  }

  Future<void> updateActivity(
      String docId, Map<String, dynamic> updatedData) async {
    await firestore.collection('activities').doc(docId).update(updatedData);
  }

  Future<void> deleteActivity(String docId) async {
    await firestore.collection('activities').doc(docId).delete();
  }
}
