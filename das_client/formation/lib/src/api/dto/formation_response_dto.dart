import 'package:collection/collection.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'formation_response_dto.g.dart';

@JsonSerializable()
class FormationResponseDto({required final List<FormationDto> data}) {
  factory fromJson(Map<String, dynamic> json) => _$FormationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FormationResponseDtoToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormationResponseDto && runtimeType == other.runtimeType && ListEquality().equals(data, other.data);

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() {
    return 'FormationResponseDto{data: $data}';
  }
}
