import 'package:external_links/src/api/external_links_api_service_impl.dart';
import 'package:external_links/src/data/local/external_links_database_service_impl.dart';
import 'package:external_links/src/repository/external_links_repository.dart';
import 'package:external_links/src/repository/external_links_repository_impl.dart';
import 'package:http_x/component.dart';

export 'package:external_links/src/model/external_link.dart';
export 'package:external_links/src/model/localized_string.dart';
export 'package:external_links/src/repository/external_links_repository.dart';

class ExternalLinksComponent {
  const ExternalLinksComponent._();

  static ExternalLinksRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return ExternalLinksRepositoryImpl(
      apiService: ExternalLinksApiServiceImpl(baseUrl: baseUrl, httpClient: client),
      databaseService: ExternalLinksDatabaseServiceImpl.instance,
    );
  }
}
