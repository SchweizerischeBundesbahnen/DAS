import 'package:json_annotation/json_annotation.dart';

part 'ru_feature_dto.g.dart';

@JsonSerializable()
class RuFeatureDto {
  RuFeatureDto({required this.companyCode, required this.key, required this.enabled});

  factory RuFeatureDto.fromJson(Map<String, dynamic> json) {
    return _$RuFeatureDtoFromJson(json);
  }

  final String companyCode;
  final String key;
  final bool enabled;
}
