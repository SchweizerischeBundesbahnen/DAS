class TrainJourneyLinkData {
  TrainJourneyLinkData({
    required this.operationalTrainNumber,
    required this.company,
    required this.startDate,
    this.tafTapLocationReferenceEnd,
    this.tafTapLocationReferenceStart,
    this.returnUrl,
  });

  final String operationalTrainNumber;
  final String? company;
  final DateTime? startDate;
  final String? tafTapLocationReferenceStart;
  final String? tafTapLocationReferenceEnd;
  final String? returnUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainJourneyLinkData &&
          runtimeType == other.runtimeType &&
          operationalTrainNumber == other.operationalTrainNumber &&
          company == other.company &&
          startDate == other.startDate &&
          tafTapLocationReferenceStart == other.tafTapLocationReferenceStart &&
          tafTapLocationReferenceEnd == other.tafTapLocationReferenceEnd &&
          returnUrl == other.returnUrl;

  @override
  int get hashCode => Object.hash(
    operationalTrainNumber,
    company,
    startDate,
    tafTapLocationReferenceStart,
    tafTapLocationReferenceEnd,
    returnUrl,
  );

  @override
  String toString() {
    return 'TrainJourneyLinkData{operationalTrainNumber: $operationalTrainNumber, company: $company, startDate: $startDate, tafTapLocationReferenceStart: $tafTapLocationReferenceStart, tafTapLocationReferenceEnd: $tafTapLocationReferenceEnd, returnUrl: $returnUrl}';
  }
}
