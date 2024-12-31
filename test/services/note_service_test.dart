import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:health_app/services/note_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NoteService noteService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    noteService = NoteService(firestore: fakeFirestore);
  });

  test('getNotes returns a stream of notes', () async {
    await fakeFirestore.collection('notes').add({
      'title': 'Meeting Notes',
      'content': 'Discuss project updates',
    });

    await fakeFirestore.collection('notes').add({
      'title': 'Shopping List',
      'content': 'Buy groceries',
    });

    final notesStream = noteService.getNotes();

    expect(
      notesStream,
      emits([
        {
          'title': 'Meeting Notes',
          'content': 'Discuss project updates',
          'imagePath': '',
        },
        {
          'title': 'Shopping List',
          'content': 'Buy groceries',
          'imagePath': '',
        },
      ]),
    );
  });
}
