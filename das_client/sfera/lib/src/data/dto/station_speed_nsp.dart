import 'package:sfera/src/data/dto/taf_tap_location_nsp.dart';
import 'package:sfera/src/data/dto/xml_graduated_speed_info.dart';
import 'package:sfera/src/data/dto/xml_station_speed.dart';

class StationSpeedNsp extends TafTapLocationNsp {
  static const String elementName = 'stationSpeed';

  StationSpeedNsp({super.type, super.attributes, super.children, super.value});

  XmlStationSpeed get xmlStationSpeed => children.whereType<XmlStationSpeed>().first;

  XmlGraduatedSpeedInfo? get xmlGraduatedSpeedInfo => children.whereType<XmlGraduatedSpeedInfo>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<XmlStationSpeed>() && super.validate();
  }
}
