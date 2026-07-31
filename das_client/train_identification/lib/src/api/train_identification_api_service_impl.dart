import 'package:http_x/component.dart';
import 'package:train_identification/src/api/companies/companies_request.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';

class TrainIdentificationApiServiceImpl implements TrainIdentificationApiService {
  TrainIdentificationApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  CompaniesRequest get companies => CompaniesRequest(httpClient: httpClient, baseUrl: baseUrl);
}
