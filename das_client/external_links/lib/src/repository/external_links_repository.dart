import 'package:external_links/src/model/external_link.dart';

abstract class ExternalLinksRepository {
  const ExternalLinksRepository._();

  Future<List<ExternalLink>> reloadExternalLinksByCompanies(List<String> companies);

  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies);
}
