import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:health_app/services/habit_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late HabitService habitService;

  setUp(() {
    // Initialisiere FakeFirestore und HabitService
    fakeFirestore = FakeFirebaseFirestore();
    habitService = HabitService(firestore: fakeFirestore);
  });

  test('getHabits returns a stream of habits', () async {
    // Daten in FakeFirestore hinzufügen
    await fakeFirestore.collection('habits').add({
      'name': 'Exercise',
      'frequency': 'Daily',
    });
    await fakeFirestore.collection('habits').add({
      'name': 'Meditation',
      'frequency': 'Weekly',
    });

    // Stream von Habits abrufen
    final habitsStream = habitService.getHabits();

    // Erwartung prüfen
    expect(
      habitsStream,
      emits([
        {'name': 'Exercise', 'frequency': 'Daily', 'isCompleted': false},
        {'name': 'Meditation', 'frequency': 'Weekly', 'isCompleted': false},
      ]),
    );
  });
}
