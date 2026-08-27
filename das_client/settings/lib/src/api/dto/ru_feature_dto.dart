import 'package:json_annotation/json_annotation.dart';

part 'ru_feature_dto.g.dart';

@JsonSerializable()
class RuFeatureDto({
  required final String companyCode,
  required final String key,
  required final bool enabled,
}) {
  factory RuFeatureDto.fromJson(Map<String, dynamic> json) {
    return _$RuFeatureDtoFromJson(json);
  }
}
