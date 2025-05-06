import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/xml_station_speed_dto.dart';

class StationSpeedNspDto extends TafTapLocationNspDto {
  static const String elementName = 'stationSpeed';

  StationSpeedNspDto({super.type, super.attributes, super.children, super.value});

  XmlStationSpeedDto get xmlStationSpeed => children.whereType<XmlStationSpeedDto>().first;

  XmlGraduatedSpeedInfoDto? get xmlGraduatedSpeedInfo => children.whereType<XmlGraduatedSpeedInfoDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<XmlStationSpeedDto>() && super.validate();
  }
}
