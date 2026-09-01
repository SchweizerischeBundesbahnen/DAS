import 'package:app_links_x/component.dart';
import 'package:json_annotation/json_annotation.dart';

part 'train_journey_dto.g.dart';

@JsonSerializable()
class TrainJourneyDto({
  // TODO: Add validation for train number when no more alpha chars (i.e. not T9999M)
  required final String operationalTrainNumber,
  final String? company,
  final DateTime? startDate,
  final String? tafTapLocationReferenceEnd,
  final String? tafTapLocationReferenceStart,
}) {
  factory fromJson(Map<String, dynamic> json) => _$TrainJourneyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TrainJourneyDtoToJson(this);
}

extension TrainJourneyDtoX on TrainJourneyDto {
  TrainJourneyLinkData toLinkData(String? returnUrl) {
    return TrainJourneyLinkData(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      startDate: startDate,
      tafTapLocationReferenceStart: tafTapLocationReferenceStart,
      tafTapLocationReferenceEnd: tafTapLocationReferenceEnd,
      returnUrl: returnUrl,
    );
  }
}
