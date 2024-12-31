import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // General helpers
  String _collectionPath(String collection) => 'users/$userId/$collection';

  // Profile-related methods
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .set(updates, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    if (userId == null) return {};
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  // Habit-related methods
  Future<void> addHabitWithData(Map<String, dynamic> habitData) async {
    if (userId == null) return;
    if (habitData['timestamp'] is DateTime) {
      habitData['timestamp'] = Timestamp.fromDate(habitData['timestamp']);
    }
    await FirebaseFirestore.instance.collection('habits').add(habitData);
  }

  Future<void> updateHabit(String docId, Map<String, dynamic> updates) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    await _db.collection(_collectionPath('habits')).doc(docId).update(updates);
  }

  Stream<QuerySnapshot> getHabitsStream() {
    return FirebaseFirestore.instance
        .collection('habits') // Direkter Zugriff auf die Sammlung
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteHabit(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('habits').doc(docId).delete();
      print('Habit gelöscht: $docId');
    } catch (e) {
      print('Fehler beim Löschen des Habits: $e');
    }
  }

  // Note-related methods
  Future<void> addNoteWithData(Map<String, dynamic> noteData) async {
    if (userId == null) return; // Benutzerprüfung
    if (noteData['timestamp'] is DateTime) {
      noteData['timestamp'] = Timestamp.fromDate(noteData['timestamp']);
    }
    await FirebaseFirestore.instance.collection('notes').add(noteData);
  }

  Future<void> updateNote(String docId, Map<String, dynamic> updates) async {
    if (userId == null) return;
    await _db.collection(_collectionPath('notes')).doc(docId).update(updates);
  }

  Stream<QuerySnapshot> getNotesStream() {
    return FirebaseFirestore.instance
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteNote(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(docId).delete();
      print('Notiz gelöscht: $docId');
    } catch (e) {
      print('Fehler beim Löschen der Notiz: $e');
    }
  }

  // Medication-related methods
  Future<void> addMedicationWithData(
      Map<String, dynamic> medicationData) async {
    if (userId == null) return;
    if (medicationData['timestamp'] is DateTime) {
      medicationData['timestamp'] =
          Timestamp.fromDate(medicationData['timestamp']);
    }
    await FirebaseFirestore.instance
        .collection('medications')
        .add(medicationData);
  }

  Future<void> updateMedication(
      String docId, Map<String, dynamic> updates) async {
    if (userId == null) return;
    await _db
        .collection(_collectionPath('medications'))
        .doc(docId)
        .update(updates);
  }

  Stream<QuerySnapshot> getMedicationsStream() {
    return FirebaseFirestore.instance
        .collection('medications') // Direkter Zugriff auf die Sammlung
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteMedication(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(docId)
          .delete();
      print('Medikament gelöscht: $docId');
    } catch (e) {
      print('Fehler beim Löschen des Medikaments: $e');
    }
  }

  // Activity-related methods
  Future<void> addActivityWithData(Map<String, dynamic> activityData) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    if (activityData['timestamp'] is DateTime) {
      activityData['timestamp'] = Timestamp.fromDate(activityData['timestamp']);
    }
    await FirebaseFirestore.instance.collection('activities').add(activityData);
  }

  Stream<QuerySnapshot> getActivitiesStream() {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    return _db
        .collection(_collectionPath('activities'))
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateActivity(
      String docId, Map<String, dynamic> updates) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    await _db
        .collection(_collectionPath('activities'))
        .doc(docId)
        .update(updates);
  }

  Future<void> deleteActivity(String docId) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    await _db.collection(_collectionPath('activities')).doc(docId).delete();
  }

  // Sleep-related methods
  Future<void> addSleepDataWithData(Map<String, dynamic> sleepData) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    if (sleepData['timestamp'] is DateTime) {
      sleepData['timestamp'] = Timestamp.fromDate(sleepData['timestamp']);
    }
    await FirebaseFirestore.instance.collection('sleep_data').add(sleepData);
  }

  Stream<QuerySnapshot> getSleepDataStream() {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    return _db
        .collection(_collectionPath('sleepData'))
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateSleepData(
      String docId, Map<String, dynamic> updates) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    await _db
        .collection(_collectionPath('sleepData'))
        .doc(docId)
        .update(updates);
  }

  Future<void> deleteSleepData(String docId) async {
    if (userId == null) throw Exception('Benutzer ist nicht eingeloggt.');
    await _db.collection(_collectionPath('sleepData')).doc(docId).delete();
  }

  addNote(Map<String, Object> noteData) {}
}
