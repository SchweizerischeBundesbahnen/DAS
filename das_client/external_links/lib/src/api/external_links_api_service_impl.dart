import 'package:external_links/src/api/endpoint/external_links.dart';
import 'package:external_links/src/api/external_links_api_service.dart';
import 'package:http_x/component.dart';

class ExternalLinksApiServiceImpl({required final String baseUrl, required final Client httpClient})
    implements ExternalLinksApiService {
  @override
  ExternalLinksRequest externalLinks(List<String> companies) =>
      ExternalLinksRequest(httpClient: httpClient, baseUrl: baseUrl, companies: companies);
}
