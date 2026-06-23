import 'package:external_links/src/api/endpoint/external_links.dart';
import 'package:external_links/src/api/external_links_api_service.dart';
import 'package:http_x/component.dart';

class ExternalLinksApiServiceImpl implements ExternalLinksApiService {
  ExternalLinksApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  ExternalLinksRequest externalLinks(List<String> companies) =>
      ExternalLinksRequest(httpClient: httpClient, baseUrl: baseUrl, companies: companies);
}
