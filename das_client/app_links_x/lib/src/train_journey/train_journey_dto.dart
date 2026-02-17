import 'package:app_links_x/component.dart';
import 'package:json_annotation/json_annotation.dart';

part 'train_journey_dto.g.dart';

@JsonSerializable()
class TrainJourneyDto {
  TrainJourneyDto({
    required this.operationalTrainNumber,
    this.company,
    this.startDate,
    this.tafTapLocationReferenceEnd,
    this.tafTapLocationReferenceStart,
  });

  factory TrainJourneyDto.fromJson(Map<String, dynamic> json) {
    return _$TrainJourneyDtoFromJson(json);
  }

  // TODO: Add validation for train number when no more alpha chars (i.e. not T9999M)
  final String operationalTrainNumber;
  final String? company;
  final DateTime? startDate;
  final String? tafTapLocationReferenceStart;
  final String? tafTapLocationReferenceEnd;

  Map<String, dynamic> toJson() => _$TrainJourneyDtoToJson(this);
}

extension TrainJourneyDtoX on TrainJourneyDto {
  TrainJourneyLinkData toLinkData() {
    return TrainJourneyLinkData(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      startDate: startDate,
      tafTapLocationReferenceStart: tafTapLocationReferenceStart,
      tafTapLocationReferenceEnd: tafTapLocationReferenceEnd,
    );
  }
}
