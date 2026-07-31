import 'package:core_data/component.dart';

class CompanyMatch {
  const CompanyMatch({
    required this.ru,
    required this.startDate,
  });

  final RailwayUndertaking ru;
  final DateTime startDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyMatch && runtimeType == other.runtimeType && ru == other.ru && startDate == other.startDate;

  @override
  int get hashCode => Object.hash(ru, startDate);

  @override
  String toString() {
    return 'CompanyMatch{ru: $ru, startDate: $startDate}';
  }
}
