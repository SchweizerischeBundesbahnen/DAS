import 'package:http_x/component.dart';
import 'package:logging/logging.dart';

final _log = Logger('RetrieveAuthTokenRequest');

class const RetrieveAuthTokenRequest({required final String tokenExchangeUrl, required final Client httpClient}) {
  Future<RetrieveAuthTokenResponse> call(String ru, String train, String role) async {
    _log.info('Trying to fetch sfera auth token for ru=$ru train=$train role=$role...');
    final url = Uri.parse('$tokenExchangeUrl?ru=$ru&train=$train&role=$role');

    final response = await httpClient.get(url);
    return RetrieveAuthTokenResponse.fromHttpResponse(response);
  }
}

class const RetrieveAuthTokenResponse({required final Map<String, String> headers, required final String token}) {
  factory fromHttpResponse(Response response) {
    final status = response.statusCode;
    final isSuccess = status >= 200 && status < 300;
    if (isSuccess) {
      return RetrieveAuthTokenResponse(headers: response.headers, token: response.body);
    }
    // Failure
    throw HttpException.fromResponse(response);
  }
}
