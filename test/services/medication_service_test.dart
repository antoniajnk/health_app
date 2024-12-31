import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:health_app/services/medication_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MedicationService medicationService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    medicationService = MedicationService(firestore: fakeFirestore);
  });

  test('getMedications returns a stream of medications', () async {
    await fakeFirestore.collection('medications').add({
      'name': 'Ibuprofen',
      'dose': '10mg',
      'duration': '7 Tage',
    });

    await fakeFirestore.collection('medications').add({
      'name': 'Paracetamol',
      'dose': '500mg',
      'duration': '3 Tage',
    });

    final medicationsStream = medicationService.getMedications();

    expect(
      medicationsStream,
      emits([
        {
          'name': 'Ibuprofen',
          'dose': '10mg',
          'duration': '7 Tage',
          'imagePath': '',
        },
        {
          'name': 'Paracetamol',
          'dose': '500mg',
          'duration': '3 Tage',
          'imagePath': '',
        },
      ]),
    );
  });
}
