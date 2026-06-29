import 'package:<feature>/src/api/<action>/<action>_request.dart';
import 'package:<feature>/src/api/feature_api_service.dart';
import 'package:http_x/component.dart';

class FeatureApiServiceImpl implements FeatureApiService {
  FeatureApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  ActionRequest get action => ActionRequest(httpClient: httpClient, baseUrl: baseUrl);
}
