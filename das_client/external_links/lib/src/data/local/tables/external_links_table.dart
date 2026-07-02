import 'package:core_data/component.dart';
import 'package:drift/drift.dart';
import 'package:external_links/src/data/local/external_links_database.dart';
import 'package:external_links/src/model/external_link.dart';

class ExternalLinksTable extends Table {
  IntColumn get id => integer()();

  TextColumn get companies => text()();

  TextColumn get titleDe => text().nullable()();

  TextColumn get titleFr => text().nullable()();

  TextColumn get titleIt => text().nullable()();

  TextColumn get linkDe => text().nullable()();

  TextColumn get linkFr => text().nullable()();

  TextColumn get linkIt => text().nullable()();

  DateTimeColumn get lastModifiedAt => dateTime()();

  TextColumn get lastModifiedBy => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

extension ExternalLinkX on ExternalLink {
  ExternalLinksTableCompanion toCompanion() {
    return ExternalLinksTableCompanion(
      id: Value(id),
      companies: Value(companies.join(',')),
      titleDe: title.de != null ? Value(title.de!) : const Value.absent(),
      titleFr: title.fr != null ? Value(title.fr!) : const Value.absent(),
      titleIt: title.it != null ? Value(title.it!) : const Value.absent(),
      linkDe: link.de != null ? Value(link.de!) : const Value.absent(),
      linkFr: link.fr != null ? Value(link.fr!) : const Value.absent(),
      linkIt: link.it != null ? Value(link.it!) : const Value.absent(),
      lastModifiedAt: Value(lastModifiedAt),
      lastModifiedBy: Value(lastModifiedBy),
    );
  }
}

extension ExternalLinksDatabaseX on ExternalLinksTableData {
  ExternalLink toDomain() {
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
