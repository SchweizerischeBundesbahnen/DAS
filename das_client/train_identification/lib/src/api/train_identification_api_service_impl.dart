import 'package:http_x/component.dart';
import 'package:train_identification/src/api/companies/companies_request.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';

class TrainIdentificationApiServiceImpl({required final String baseUrl, required final Client httpClient})
    implements TrainIdentificationApiService {
  @override
  CompaniesRequest get companies => CompaniesRequest(httpClient: httpClient, baseUrl: baseUrl);
}
