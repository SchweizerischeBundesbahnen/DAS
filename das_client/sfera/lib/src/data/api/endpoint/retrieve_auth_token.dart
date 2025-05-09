import 'package:fimber/fimber.dart';
import 'package:http_x/component.dart';

class RetrieveAuthTokenRequest {
  const RetrieveAuthTokenRequest({required this.tokenExchangeUrl, required this.httpClient});

  final String tokenExchangeUrl;
  final Client httpClient;

  Future<RetrieveAuthTokenResponse> call(String ru, String train, String role) async {
    Fimber.i('Trying to fetch sfera auth token for ru=$ru train=$train role=$role...');
    final url = Uri.parse('$tokenExchangeUrl?ru=$ru&train=$train&role=$role');

    final response = await httpClient.get(url);
    return RetrieveAuthTokenResponse.fromHttpResponse(response);
  }
}

class RetrieveAuthTokenResponse {
  const RetrieveAuthTokenResponse({required this.headers, required this.token});

  factory RetrieveAuthTokenResponse.fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return RetrieveAuthTokenResponse(headers: response.headers, token: response.body);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }

  final Map<String, String> headers;
  final String token;
}
