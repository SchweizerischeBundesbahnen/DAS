import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/dto/personal_notes_data_dto.dart';

class PersonalNoteGetRequest({
  required final Client httpClient,
  required final String baseUrl,
}) {
  Future<PersonalNoteGetResponse> call({required String key}) async {
    final url = Uri.https(baseUrl, 'driver/v1/personal-notes/$key');
    final response = await httpClient.get(url);
    return PersonalNoteGetResponse.fromHttpResponse(response);
  }
}

class PersonalNoteGetResponse({
  required final Map<String, String> headers,
  required final PersonalNoteDto body,
}) {
  factory PersonalNoteGetResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString);
      final dto = PersonalNotesDataDto.fromJson(json);
      return PersonalNoteGetResponse(headers: response.headers, body: dto.data.first);
    }
    throw HttpException.fromResponse(response);
  }
}
