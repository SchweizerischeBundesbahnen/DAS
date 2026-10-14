import 'package:http_x/component.dart';

class PersonalNoteDeleteRequest({
  required final Client httpClient,
  required final String baseUrl,
}) {
  Future<PersonalNoteDeleteResponse> call({required String key}) async {
    final url = Uri.https(baseUrl, 'driver/v1/personal-notes/$key');
    final response = await httpClient.delete(url);
    return PersonalNoteDeleteResponse.fromHttpResponse(response);
  }
}

class PersonalNoteDeleteResponse({required final Map<String, String> headers}) {
  factory PersonalNoteDeleteResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return PersonalNoteDeleteResponse(headers: response.headers);
    }
    throw HttpException.fromResponse(response);
  }
}
