import 'package:http_x/component.dart';
import 'package:personal_notes/src/api/endpoint/delete_personal_note.dart';
import 'package:personal_notes/src/api/endpoint/get_personal_note.dart';
import 'package:personal_notes/src/api/endpoint/personal_notes.dart';
import 'package:personal_notes/src/api/endpoint/save_personal_notes.dart';
import 'package:personal_notes/src/api/personal_notes_api_service.dart';

class PersonalNotesApiServiceImpl({required final String baseUrl, required final Client httpClient})
    implements PersonalNotesApiService {
  @override
  PersonalNotesListRequest get personalNotes => PersonalNotesListRequest(baseUrl: baseUrl, httpClient: httpClient);

  @override
  PersonalNoteGetRequest get getPersonalNote => PersonalNoteGetRequest(baseUrl: baseUrl, httpClient: httpClient);

  @override
  PersonalNotePutRequest get savePersonalNote => PersonalNotePutRequest(baseUrl: baseUrl, httpClient: httpClient);

  @override
  PersonalNoteDeleteRequest get deletePersonalNote =>
      PersonalNoteDeleteRequest(baseUrl: baseUrl, httpClient: httpClient);
}
