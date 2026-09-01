import 'package:formation/src/api/endpoint/formation.dart';
import 'package:formation/src/api/endpoint/transport_paper.dart';
import 'package:formation/src/api/formation_api_service.dart';
import 'package:http_x/component.dart';

class FormationApiServiceImpl({
  required final String baseUrl,
  required final Client httpClient,
}) implements FormationApiService {
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

  @override
  TransportPaperRequest transportPaper(String relativeUrl) =>
      TransportPaperRequest(httpClient: httpClient, baseUrl: baseUrl, relativeUrl: relativeUrl);
}
