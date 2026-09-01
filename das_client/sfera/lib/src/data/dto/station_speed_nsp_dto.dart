import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/xml_station_speed_dto.dart';

class StationSpeedNspDto({super.type, super.attributes, super.children, super.value}) extends TafTapLocationNspDto {
  static const String groupNameValue = 'stationSpeed';

  XmlStationSpeedDto? get xmlStationSpeed => children.whereType<XmlStationSpeedDto>().firstOrNull;

  XmlGraduatedSpeedInfoDto? get xmlGraduatedSpeedInfo => children.whereType<XmlGraduatedSpeedInfoDto>().firstOrNull;
}
