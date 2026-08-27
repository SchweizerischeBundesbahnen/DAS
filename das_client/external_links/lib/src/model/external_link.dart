import 'package:collection/collection.dart';
import 'package:core_data/component.dart';

class ExternalLink({
  required final int id,
  required final List<String> companies,
  required final LocalizedString title,
  required final LocalizedString link,
  required final DateTime lastModifiedAt,
  required final String lastModifiedBy,
}) {
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
