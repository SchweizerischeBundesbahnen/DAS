import 'package:http_x/component.dart';
import 'package:ru_indications/src/api/matches/matches_request.dart';
import 'package:ru_indications/src/api/ru_indications_api_service.dart';

class RuIndicationsApiServiceImpl implements RuIndicationsApiService {
  RuIndicationsApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  MatchesRequest get matches => MatchesRequest(httpClient: httpClient, baseUrl: baseUrl);
}
