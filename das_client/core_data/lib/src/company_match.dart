import 'package:core_data/src/company.dart';

class CompanyMatch {
  const CompanyMatch({
    required this.company,
    required this.startDate,
  });

  final Company company;
  final DateTime startDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyMatch &&
          runtimeType == other.runtimeType &&
          company == other.company &&
          startDate == other.startDate;

  @override
  int get hashCode => Object.hash(company, startDate);

  @override
  String toString() {
    return 'CompanyMatch{company: $company, startDate: $startDate}';
  }
}
