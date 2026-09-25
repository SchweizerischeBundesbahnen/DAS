import 'package:json_annotation/json_annotation.dart';

part 'user_properties_options_dto.g.dart';

@JsonSerializable()
class UserPropertiesOptionsDto({
  required final bool decisiveGradientSwitch,
  required final bool stationSignalSwitch,
  required final bool ectsConventionalSpeedSignalSwitch,
  required final bool ectsExtendedSpeedSignalSwitch,
}) {
  factory UserPropertiesOptionsDto.fromJson(Map<String, dynamic> json) => _$UserPropertiesOptionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserPropertiesOptionsDtoToJson(this);
}
