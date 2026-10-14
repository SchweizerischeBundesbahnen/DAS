import 'package:personal_notes/component.dart';
import 'package:rxdart/rxdart.dart';

class MockPersonalNotesRepository implements PersonalNotesRepository {
  final _rxPersonalNotes = BehaviorSubject<List<PersonalNote>>.seeded(const []);

  void initializeWith(List<PersonalNote> notes) => _rxPersonalNotes.add(notes);

  @override
  Future<void> deleteNote(PersonalNote note) async =>
      _rxPersonalNotes.add(_rxPersonalNotes.value.where((it) => it != note).toList());

  @override
  Stream<List<PersonalNote>> observeAllNotes() => _rxPersonalNotes.stream;

  @override
  Stream<List<PersonalNote>> observeNotes(String locationCode) =>
      _rxPersonalNotes.stream.map((notes) => notes.where((note) => note.locationCode == locationCode).toList());

  @override
  Future<void> saveNote(PersonalNote note) async => _rxPersonalNotes.add([..._rxPersonalNotes.value, note]);

  @override
  Future<void> synchronizeNotes() async {
    // unused
  }

  @override
  void dispose() {
    _rxPersonalNotes.close();
  }
}
