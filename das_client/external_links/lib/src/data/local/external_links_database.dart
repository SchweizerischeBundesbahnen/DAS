import 'package:drift/drift.dart';
import 'package:external_links/src/data/local/tables/external_links_table.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/localized_string.dart';

part 'external_links_database.g.dart';

@DriftDatabase(tables: [ExternalLinksTable])
class ExternalLinksDatabase extends _$ExternalLinksDatabase {
  ExternalLinksDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<void> saveExternalLinks(List<ExternalLink> externalLinks) async {
    await batch((batch) {
      batch.insertAll(
        externalLinksTable,
        externalLinks
            .map(
              (link) => ExternalLinksTableCompanion(
                id: Value(link.id),
                companies: Value(link.companies.join(',')),
                titleDe: Value(link.title.de ?? ''),
                titleFr: Value(link.title.fr ?? ''),
                titleIt: Value(link.title.it ?? ''),
                linkDe: Value(link.link.de ?? ''),
                linkFr: Value(link.link.fr ?? ''),
                linkIt: Value(link.link.it ?? ''),
                lastModifiedAt: Value(link.lastModifiedAt),
                lastModifiedBy: Value(link.lastModifiedBy),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> deleteExternalLinks() => delete(externalLinksTable).go();

  Future<List<ExternalLink>> findExternalLinksByCompanies(List<String> companies) async {
    final rows = await select(externalLinksTable).get();
    return rows
        .where((row) {
          final rowCompanies = row.companies.split(',');
          return rowCompanies.any((c) => companies.contains(c));
        })
        .map((row) => row.toModel())
        .toList();
  }

  Stream<List<ExternalLink>> watchExternalLinksByCompanies(List<String> companies) {
    return (select(externalLinksTable).watch()).map((rows) {
      return rows
          .where((row) {
            final rowCompanies = row.companies.split(',');
            return rowCompanies.any((c) => companies.contains(c));
          })
          .map((row) => row.toModel())
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

extension ExternalLinksDatabaseExtension on ExternalLinksTableData {
  ExternalLink toModel() {
    return ExternalLink(
      id: id,
      companies: companies.split(','),
      title: LocalizedString(
        de: titleDe,
        fr: titleFr,
        it: titleIt,
      ),
      link: LocalizedString(
        de: linkDe,
        fr: linkFr,
        it: linkIt,
      ),
      lastModifiedAt: lastModifiedAt,
      lastModifiedBy: lastModifiedBy,
    );
  }
}
