import 'package:collection/collection.dart';
import 'package:external_links/src/model/localized_string.dart';

class ExternalLink {
  ExternalLink({
    required this.id,
    required this.companies,
    required this.title,
    required this.link,
    required this.lastModifiedAt,
    required this.lastModifiedBy,
  });

  final int id;
  final List<String> companies;
  final LocalizedString title;
  final LocalizedString link;
  final DateTime lastModifiedAt;
  final String lastModifiedBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalLink &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ListEquality().equals(companies, other.companies) &&
          title == other.title &&
          link == other.link &&
          lastModifiedAt == other.lastModifiedAt &&
          lastModifiedBy == other.lastModifiedBy;

  @override
  int get hashCode => Object.hash(id, ListEquality().hash(companies), title, link, lastModifiedAt, lastModifiedBy);
}
