import 'package:das_client/sfera/src/model/taf_tap_location_nsp.dart';
import 'package:das_client/sfera/src/model/xml_station_speed.dart';

class StationSpeedNsp extends TafTapLocationNsp {
  static const String elementName = 'stationSpeed';

  StationSpeedNsp({super.type, super.attributes, super.children, super.value});

  XmlStationSpeed get xmlStationSpeed => children.whereType<XmlStationSpeed>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlStationSpeed>() && super.validate();
  }
}
