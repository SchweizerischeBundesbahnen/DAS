import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/xml_curve_speed_dto.dart';

class CurvePointNetworkSpecificPointDto extends NetworkSpecificPointDto {
  static const String elementName = 'curvePoint';

  CurvePointNetworkSpecificPointDto({super.type, super.attributes, super.children, super.value});

  XmlCurveSpeedDto? get xmlCurveSpeed => parameters.whereType<XmlCurveSpeedDto>().firstOrNull;

  String? get curvePointType => parameters.withName('curvePointType')?.nspValue;

  String? get curveType => parameters.withName('curveType')?.nspValue;
}
