import 'package:external_links/src/api/external_links_api_service.dart';
import 'package:external_links/src/data/local/external_links_database_service.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/repository/external_links_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('ExternalLinksRepositoryImpl');

class ExternalLinksRepositoryImpl({
  required final ExternalLinksApiService _apiService,
  required final ExternalLinksDatabaseService _databaseService,
}) implements ExternalLinksRepository {
  @override
  Future<List<ExternalLink>> reloadExternalLinksByCompanies(List<String> companies) async {
    await _loadExternalLinksAndUpdateDatabase(companies);
    return _databaseService.findExternalLinksByCompanies(companies);
  }

  Future<void> _loadExternalLinksAndUpdateDatabase(List<String> companies) async {
    _log.info('Loading external links for companies: $companies');
    try {
      final response = await _apiService.externalLinks(companies).call();
      final externalLinks = response.body.data.map((dto) => dto.toModel()).toList();

      await _databaseService.saveExternalLinks(externalLinks);

      // Cleanup
      final fetchedIds = externalLinks.map((link) => link.id).toList();
      await _databaseService.deleteExternalLinksNotIn(fetchedIds);

      _log.info('External links loaded successfully. Count: ${externalLinks.length}');
    } catch (e) {
      _log.severe('Error while loading external links', e);
    }
  }

  @override
  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) {
    reloadExternalLinksByCompanies(companies);

    return _databaseService.watchExternalLinksByCompanies(companies);
  }
}
