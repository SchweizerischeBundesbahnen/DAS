import 'package:http_x/component.dart';
import 'package:ru_indications/src/api/matches/matches_request.dart';
import 'package:ru_indications/src/api/ru_indications_api_service.dart';

class RuIndicationsApiServiceImpl({
  required final String baseUrl,
  required final Client httpClient,
}) implements RuIndicationsApiService {
  @override
  MatchesRequest get matches => MatchesRequest(httpClient: httpClient, baseUrl: baseUrl);
}
