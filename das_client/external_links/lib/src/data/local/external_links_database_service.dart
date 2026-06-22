import 'package:external_links/src/model/external_link.dart';

abstract class ExternalLinksDatabaseService {
  Future<void> saveExternalLinks(List<ExternalLink> externalLinks);

  Future<void> deleteExternalLinks();

  Future<List<ExternalLink>> findExternalLinksByCompanies(List<String> companies);

  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies);

  Future<void> deleteExternalLinksNotIn(List<int> keepIds);
}
