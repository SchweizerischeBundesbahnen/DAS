class TrainJourneyLinkData {
  TrainJourneyLinkData({
    required this.operationalTrainNumber,
    required this.company,
    required this.startDate,
    this.tafTapLocationReferenceEnd,
    this.tafTapLocationReferenceStart,
  });

  final String operationalTrainNumber;
  final String? company;
  final DateTime? startDate;
  final String? tafTapLocationReferenceStart;
  final String? tafTapLocationReferenceEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainJourneyLinkData &&
          runtimeType == other.runtimeType &&
          operationalTrainNumber == other.operationalTrainNumber &&
          company == other.company &&
          startDate == other.startDate &&
          tafTapLocationReferenceStart == other.tafTapLocationReferenceStart &&
          tafTapLocationReferenceEnd == other.tafTapLocationReferenceEnd;

  @override
  int get hashCode =>
      Object.hash(operationalTrainNumber, company, startDate, tafTapLocationReferenceStart, tafTapLocationReferenceEnd);

  @override
  String toString() {
    return 'TrainJourneyLinkData{operationalTrainNumber: $operationalTrainNumber, company: $company, startDate: $startDate, tafTapLocationReferenceStart: $tafTapLocationReferenceStart, tafTapLocationReferenceEnd: $tafTapLocationReferenceEnd}';
  }
}
