import 'package:meta/meta.dart';

@sealed
@immutable
class const BracketMainStation({
  required final String countryCode,
  required final int primaryCode,
  required final String abbreviation,
}) {
  @override
  String toString() {
    return 'BracketMainStation{countryCode: $countryCode, primaryCode: $primaryCode, abbreviation: $abbreviation}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BracketMainStation &&
          runtimeType == other.runtimeType &&
          countryCode == other.countryCode &&
          primaryCode == other.primaryCode &&
          abbreviation == other.abbreviation;

  @override
  int get hashCode => countryCode.hashCode ^ primaryCode.hashCode ^ abbreviation.hashCode;
}
