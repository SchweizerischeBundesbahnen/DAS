import 'dart:io';

import 'package:http_x/component.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/dto/personal_notes_data_dto.dart';

class PersonalNotePutRequest({
  required final Client httpClient,
  required final String baseUrl,
}) {
  Future<PersonalNotePutResponse> call({required String key, required PersonalNoteDto note}) async {
    final body = PersonalNotesDataDto(data: [note]);
    final url = Uri.https(baseUrl, 'driver/v1/personal-notes/$key');
    final response = await httpClient.put(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: body.toJsonString(),
    );

    return PersonalNotePutResponse.fromHttpResponse(response);
  }
}

class PersonalNotePutResponse({required final Map<String, String> headers}) {
  factory PersonalNotePutResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return PersonalNotePutResponse(headers: response.headers);
    }
    throw HttpException.fromResponse(response);
  }
}
