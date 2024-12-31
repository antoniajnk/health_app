import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:health_app/services/activity_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ActivityService activityService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    activityService = ActivityService(firestore: fakeFirestore);
  });

  test('getActivities returns a stream of activities', () async {
    await fakeFirestore.collection('activities').add({
      'name': 'Running',
      'duration': '30 minutes',
      'distance': '5 km',
    });

    await fakeFirestore.collection('activities').add({
      'name': 'Cycling',
      'duration': '60 minutes',
      'distance': '20 km',
    });

    final activitiesStream = activityService.getActivities();

    expect(
      activitiesStream,
      emits([
        {
          'name': 'Running',
          'duration': '30 minutes',
          'distance': '5 km',
          'imagePath': '',
        },
        {
          'name': 'Cycling',
          'duration': '60 minutes',
          'distance': '20 km',
          'imagePath': '',
        },
      ]),
    );
  });
}
