import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';

class TafTapRouteTableDataNspDto extends TafTapLocationNspDto {
  static const String elementName = 'routeTableData';

  TafTapRouteTableDataNspDto({super.type, super.attributes, super.children, super.value});

  StationSign? get stationSign1 => children
      .whereType<NetworkSpecificParameterDto>()
      .where((it) => it.name == 'stationSign1')
      .map((it) => StationSign.from(it.nspValue))
      .firstOrNull;

  StationSign? get stationSign2 => children
      .whereType<NetworkSpecificParameterDto>()
      .where((it) => it.name == 'stationSign2')
      .map((it) => StationSign.from(it.nspValue))
      .firstOrNull;

  bool get betweenBrackets =>
      children
          .whereType<NetworkSpecificParameterDto>()
          .where((it) => it.name == 'betweenBrackets')
          .map((it) => bool.tryParse(it.nspValue))
          .firstOrNull ??
      false;
}
