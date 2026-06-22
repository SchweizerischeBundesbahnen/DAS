import 'package:drift/drift.dart';
import 'package:external_links/src/data/local/tables/external_links_table.dart';
import 'package:external_links/src/model/external_link.dart';

part 'external_links_database.g.dart';

@DriftDatabase(tables: [ExternalLinksTable])
class ExternalLinksDatabase extends _$ExternalLinksDatabase {
  ExternalLinksDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<void> saveExternalLinks(List<ExternalLink> externalLinks) async {
    await managers.externalLinksTable.bulkCreate(
      (_) => externalLinks.map((it) => it.toCompanion()),
      mode: .insertOrReplace,
    );
  }

  Future<void> deleteExternalLinks() => delete(externalLinksTable).go();

  Future<List<ExternalLink>> findExternalLinksByCompanies(List<String> companies) async {
    final rows = await select(externalLinksTable).get();
    return rows
        .where((row) {
          final rowCompanies = row.companies.split(',');
          return rowCompanies.any((c) => companies.contains(c));
        })
        .map((row) => row.toDomain())
        .toList();
  }

  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) {
    return (select(externalLinksTable).watch()).map((rows) {
      return rows
          .where((row) {
            final rowCompanies = row.companies.split(',');
            return rowCompanies.any((c) => companies.contains(c));
          })
          .map((row) => row.toDomain())
          .toList();
    });
  }

  Future<void> deleteExternalLinksNotIn(List<int> keepIds) async {
    if (keepIds.isEmpty) {
      return deleteExternalLinks();
    }
    await (delete(externalLinksTable)..where((tbl) => tbl.id.isNotIn(keepIds))).go();
  }
}
