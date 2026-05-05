import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/route_table_data_relevant_wrapper_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class TafTapRouteTableDataNspDto extends TafTapLocationNspDto {
  static const String groupNameValue = 'routeTableData';

  TafTapRouteTableDataNspDto({super.type, super.attributes, super.children, super.value});

  StationSign? get stationSign1 =>
      children.whereNspWithName('stationSign1').map((it) => StationSign.from(it.nspValue)).firstOrNull;

  StationSign? get stationSign2 =>
      children.whereNspWithName('stationSign2').map((it) => StationSign.from(it.nspValue)).firstOrNull;

  RouteTableDataRelevantWrapperDto? get routeTableDataRelevant =>
      children.whereType<RouteTableDataRelevantWrapperDto>().firstOrNull;

  bool get betweenBrackets =>
      children.whereNspWithName('betweenBrackets').map((it) => bool.tryParse(it.nspValue)).firstOrNull ?? false;

  String? get trackGroup => children.whereNspWithName('trackGroup').firstOrNull?.nspValue;

  double? get km1 => ParseUtils.tryParseDouble(children.whereNspWithName('km1').map((it) => it.nspValue).firstOrNull);

  double? get km2 => ParseUtils.tryParseDouble(children.whereNspWithName('km2').map((it) => it.nspValue).firstOrNull);
}
