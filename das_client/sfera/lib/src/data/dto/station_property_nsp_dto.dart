import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_station_property_dto.dart';

class StationPropertyNspDto extends TafTapLocationNspDto {
  static const String elementName = 'stationProperty';

  StationPropertyNspDto({super.type, super.attributes, super.children, super.value});

  XmlStationPropertyDto get xmlStationProperty => children.whereType<XmlStationPropertyDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlStationPropertyDto>() && super.validate();
  }
}
