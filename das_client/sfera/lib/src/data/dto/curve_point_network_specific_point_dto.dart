import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/xml_curve_speed_dto.dart';

class CurvePointNetworkSpecificPointDto({super.type = groupNameValue, super.attributes, super.children, super.value})
    extends NetworkSpecificPointDto {
  static const String groupNameValue = 'curvePoint';

  XmlCurveSpeedDto? get xmlCurveSpeed => parameters.whereType<XmlCurveSpeedDto>().firstOrNull;

  String? get curvePointType => parameters.withName('curvePointType')?.nspValue;

  String? get curveType => parameters.withName('curveType')?.nspValue;
}
