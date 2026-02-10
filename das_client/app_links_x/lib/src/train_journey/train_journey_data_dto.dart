import 'package:app_links_x/src/train_journey/train_journey_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'train_journey_data_dto.g.dart';

@JsonSerializable()
class TrainJourneyDataDto {
  TrainJourneyDataDto({
    required this.journeys,
    this.returnUrl,
  });

  factory TrainJourneyDataDto.fromJson(Map<String, dynamic> json) {
    return _$TrainJourneyDataDtoFromJson(json);
  }

  final List<TrainJourneyDto> journeys;
  final String? returnUrl;

  Map<String, dynamic> toJson() => _$TrainJourneyDataDtoToJson(this);
}
