import 'package:drift_flutter/drift_flutter.dart';
import 'package:external_links/src/data/local/external_links_database.dart';
import 'package:external_links/src/data/local/external_links_database_service.dart';
import 'package:external_links/src/model/external_link.dart';

class ExternalLinksDatabaseServiceImpl implements ExternalLinksDatabaseService {
  ExternalLinksDatabaseServiceImpl._() : _database = _createDatabase();

  static final ExternalLinksDatabaseServiceImpl _instance = ExternalLinksDatabaseServiceImpl._();

  static ExternalLinksDatabaseServiceImpl get instance => _instance;

  final ExternalLinksDatabase _database;

  static ExternalLinksDatabase _createDatabase() {
    return ExternalLinksDatabase(driftDatabase(name: 'external_links_db'));
  }

  @override
  Future<void> saveExternalLinks(List<ExternalLink> externalLinks) => _database.saveExternalLinks(externalLinks);

  @override
  Future<void> deleteExternalLinks() => _database.deleteExternalLinks();

  @override
  Future<List<ExternalLink>> findExternalLinksByCompanies(List<String> companies) =>
      _database.findExternalLinksByCompanies(companies);

  @override
  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) =>
      _database.watchExternalLinksByCompanies(companies);

  @override
  Future<void> deleteExternalLinksNotIn(List<int> keepIds) => _database.deleteExternalLinksNotIn(keepIds);
}
