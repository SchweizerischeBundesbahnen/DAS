import 'package:json_annotation/json_annotation.dart';

part 'formation_dto.g.dart';

@JsonSerializable()
class FormationDto {
  FormationDto({required this.operationalTrainNumber, required this.company, required this.operationalDay});

  factory FormationDto.fromJson(Map<String, dynamic> json) {
    return _$FormationDtoFromJson(json);
  }

  final String operationalTrainNumber;
  final String company;
  final DateTime operationalDay;

  Map<String, dynamic> toJson() => _$FormationDtoToJson(this);
}
