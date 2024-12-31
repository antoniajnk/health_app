import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:health_app/services/sleep_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SleepService sleepService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    sleepService = SleepService(firestore: fakeFirestore);
  });

  test('getSleepRecords returns a stream of sleep records', () async {
    await fakeFirestore.collection('sleep').add({
      'date': '2023-12-31',
      'hours': '8',
      'note': 'Felt rested',
    });

    await fakeFirestore.collection('sleep').add({
      'date': '2023-12-30',
      'hours': '6',
      'note': 'Tired',
    });

    final sleepRecordsStream = sleepService.getSleepRecords();

    expect(
      sleepRecordsStream,
      emits([
        {'date': '2023-12-31', 'hours': '8', 'note': 'Felt rested'},
        {'date': '2023-12-30', 'hours': '6', 'note': 'Tired'},
      ]),
    );
  });
}
