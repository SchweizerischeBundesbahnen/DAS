import 'package:formation/src/api/endpoint/formation.dart';
import 'package:formation/src/api/formation_api_service.dart';
import 'package:http_x/component.dart';

class FormationApiServiceImpl implements FormationApiService {
  FormationApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  FormationRequest formation(String operationalTrainNumber, String company, DateTime operationalDay, String? etag) =>
      FormationRequest(
        httpClient: httpClient,
        baseUrl: baseUrl,
        operationalTrainNumber: operationalTrainNumber,
        company: company,
        operationalDay: operationalDay,
        etag: etag,
      );
}
