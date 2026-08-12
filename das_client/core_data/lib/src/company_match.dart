class CompanyMatch {
  const CompanyMatch({
    required this.companyCode,
    required this.startDate,
  });

  final String companyCode;
  final DateTime startDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyMatch &&
          runtimeType == other.runtimeType &&
          companyCode == other.companyCode &&
          startDate == other.startDate;

  @override
  int get hashCode => Object.hash(companyCode, startDate);

  @override
  String toString() {
    return 'CompanyMatch{companyCode: $companyCode, startDate: $startDate}';
  }
}
