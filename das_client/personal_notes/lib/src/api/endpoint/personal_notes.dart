import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/dto/personal_notes_data_dto.dart';

class PersonalNotesListRequest({
  required final Client httpClient,
  required final String baseUrl,
}) {
  Future<PersonalNotesListResponse> call() async {
    final url = Uri.https(baseUrl, 'driver/v1/personal-notes');
    final response = await httpClient.get(url);
    return PersonalNotesListResponse.fromHttpResponse(response);
  }
}

class PersonalNotesListResponse({
  required final Map<String, String> headers,
  required final List<PersonalNoteDto> body,
}) {
  factory PersonalNotesListResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      final json = jsonDecode(bodyString);
      final dto = PersonalNotesDataDto.fromJson(json);
      return PersonalNotesListResponse(headers: response.headers, body: dto.data);
    }
    throw HttpException.fromResponse(response);
  }
}
