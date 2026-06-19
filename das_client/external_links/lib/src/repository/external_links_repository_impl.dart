import 'package:external_links/src/api/external_links_api_service.dart';
import 'package:external_links/src/data/local/exernal_links_service.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/repository/external_links_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('ExternalLinksRepositoryImpl');

class ExternalLinksRepositoryImpl implements ExternalLinksRepository {
  ExternalLinksRepositoryImpl({required this.apiService, required this.databaseService});

  final ExternalLinksApiService apiService;
  final ExternalLinksService databaseService;

  @override
  Future<List<ExternalLink>> reloadExternalLinksByCompanies(List<String> companies) async {
    await _loadExternalLinksAndUpdateDatabase(companies);
    return databaseService.findExternalLinksByCompanies(companies);
  }

  Future<void> _loadExternalLinksAndUpdateDatabase(List<String> companies) async {
    _log.info('Loading external links for companies: $companies');
    try {
      final response = await apiService.externalLinks(companies).call();
      final externalLinks = response.body.data.map((dto) => dto.toModel()).toList();

      await databaseService.saveExternalLinks(externalLinks);

      // Cleanup
      final fetchedIds = externalLinks.map((link) => link.id).toList();
      await databaseService.deleteExternalLinksNotIn(fetchedIds);

      _log.info('External links loaded successfully. Count: ${externalLinks.length}');
    } catch (e) {
      _log.severe('Error while loading external links', e);
    }
  }

  @override
  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) {
    reloadExternalLinksByCompanies(companies);

    return databaseService
        .watchExternalLinksByCompanies(companies)
        .distinct((links1, links2) => _listsEqual(links1, links2));
  }

  bool _listsEqual(List<ExternalLink> list1, List<ExternalLink> list2) {
    if (list1.length != list2.length) return false;
    return list1.asMap().entries.every((e) => e.value == list2[e.key]);
  }
}
