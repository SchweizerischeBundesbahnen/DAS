import 'package:external_links/src/model/external_link.dart';

abstract class ExternalLinksRepository {
  const ExternalLinksRepository._();

  /// Reloads the external links for the given companies from the backend.
  Future<List<ExternalLink>> reloadExternalLinksByCompanies(List<String> companies);

  /// Reloads and watches the external links for the given companies from the backend.
  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies);
}
