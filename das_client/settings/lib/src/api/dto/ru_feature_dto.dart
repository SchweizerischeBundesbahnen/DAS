import 'package:json_annotation/json_annotation.dart';

part 'ru_feature_dto.g.dart';

@JsonSerializable()
class RuFeatureDto {
  RuFeatureDto({required this.companyCodeRics, required this.key, required this.enabled});

  factory RuFeatureDto.fromJson(Map<String, dynamic> json) {
    return _$RuFeatureDtoFromJson(json);
  }

  final String companyCodeRics;
  final String key;
  final bool enabled;

  Map<String, dynamic> toJson() => _$RuFeatureDtoToJson(this);
}
