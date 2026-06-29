import 'dart:io';

import 'package:customer_oriented_departure/src/api/subscribe/subscribe_request_body.dart';
import 'package:http_x/component.dart';

enum SubscribeRequestType { register, deregister }

class SubscribeRequest {
  const SubscribeRequest({required this.requestType, required this.httpClient, required this.baseUrl});

  final Client httpClient;
  final String baseUrl;
  final SubscribeRequestType requestType;

  Future<SubscribeResponse> call({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  }) async {
    final url = Uri.https(baseUrl, 'driver/v1/departures/subscribe');
    final requestBody = SubscribeRequestBody(
      type: requestType.name.toUpperCase(),
      evu: evu,
      driver: isDriver,
      messageId: messageId,
      zugnr: trainNumber,
      deviceId: deviceId,
      pushToken: pushToken,
      expiresAt: expiresAt,
    );

    final response = await httpClient.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody.toJsonString(),
    );

    return SubscribeResponse.fromHttpResponse(response);
  }
}

class SubscribeResponse {
  const SubscribeResponse({required this.headers});

  factory SubscribeResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return SubscribeResponse(headers: response.headers);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
}
