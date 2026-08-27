import 'package:json_annotation/json_annotation.dart';
import 'package:train_identification/src/api/dto/company_match_dto.dart';

part 'train_identification_response_dto.g.dart';

@JsonSerializable()
class TrainIdentificationResponseDto({required final List<CompanyMatchDto> data}) {
  factory TrainIdentificationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TrainIdentificationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TrainIdentificationResponseDtoToJson(this);
}
