import 'package:external_links/src/api/endpoint/external_links.dart';

abstract class ExternalLinksApiService {
  const ExternalLinksApiService._();

  ExternalLinksRequest externalLinks(List<String> companies);
}
