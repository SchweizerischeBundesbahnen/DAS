import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/modification_type.dart';

@sealed
@immutable
class const Modification({
  required final String identifier,
  required final DateTime date,
  required final ModificationType type,
}) {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Modification &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          date == other.date &&
          type == other.type;

  @override
  int get hashCode => Object.hash(identifier, date, type);

  @override
  String toString() {
    return 'Modification{identifier: $identifier, date: $date, type: $type}';
  }
}
