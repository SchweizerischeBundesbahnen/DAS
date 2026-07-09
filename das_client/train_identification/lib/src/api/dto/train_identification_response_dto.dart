import 'package:json_annotation/json_annotation.dart';
import 'package:train_identification/src/api/dto/company_dto.dart';

part 'train_identification_response_dto.g.dart';

@JsonSerializable()
class TrainIdentificationResponseDto {
  TrainIdentificationResponseDto({required this.data});

  factory TrainIdentificationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TrainIdentificationResponseDtoFromJson(json);

  final List<CompanyDto> data;

  Map<String, dynamic> toJson() => _$TrainIdentificationResponseDtoToJson(this);
}
