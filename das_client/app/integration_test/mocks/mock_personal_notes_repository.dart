import 'package:personal_notes/component.dart';

class MockPersonalNotesRepository implements PersonalNotesRepository {
  final List<PersonalNote> _personalNotes = [];

  void initializeWith(List<PersonalNote> notes) => _personalNotes.addAll(notes);

  @override
  Future<void> deleteNote(PersonalNote note) async => _personalNotes.remove(note);

  @override
  Future<List<PersonalNote>> findAllNotes() async => _personalNotes;

  @override
  Future<List<PersonalNote>> findNotes(String locationCode) async =>
      _personalNotes.where((note) => note.locationCode == locationCode).toList();

  @override
  Future<void> saveNote(PersonalNote note) async => _personalNotes.add(note);

  @override
  Future<void> synchronizeNotes() async {
    // unused
  }

  @override
  void dispose() {
    // unused
  }
}
