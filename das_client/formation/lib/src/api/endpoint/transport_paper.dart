import 'dart:io';

import 'package:http_x/component.dart';

class TransportPaperRequest {
  const TransportPaperRequest({
    required this.httpClient,
    required this.baseUrl,
    required this.relativeUrl,
  });

  final Client httpClient;
  final String baseUrl;
  final String relativeUrl;

  Future<TransportPaperResponse> call() async {
    final url = Uri.parse('https://$baseUrl$relativeUrl');

    final request = Request('GET', url);
    request.followRedirects = false;

    final response = await httpClient.send(request);
    return TransportPaperResponse.fromHttpResponse(response);
  }
}

class TransportPaperResponse {
  const TransportPaperResponse({required this.headers});

  factory TransportPaperResponse.fromHttpResponse(StreamedResponse response) {
    final status = response.statusCode;
    if ([
      HttpStatus.movedPermanently,
      HttpStatus.movedTemporarily,
      HttpStatus.temporaryRedirect,
      HttpStatus.permanentRedirect,
    ].contains(status)) {
      return TransportPaperResponse(headers: response.headers);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
}
