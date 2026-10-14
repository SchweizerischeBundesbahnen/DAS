import 'package:personal_notes/src/api/endpoint/delete_personal_note.dart';
import 'package:personal_notes/src/api/endpoint/get_personal_note.dart';
import 'package:personal_notes/src/api/endpoint/personal_notes.dart';
import 'package:personal_notes/src/api/endpoint/save_personal_notes.dart';

abstract class PersonalNotesApiService {
  PersonalNotesListRequest get personalNotes;

  PersonalNoteGetRequest get getPersonalNote;

  PersonalNotePutRequest get savePersonalNote;

  PersonalNoteDeleteRequest get deletePersonalNote;
}
