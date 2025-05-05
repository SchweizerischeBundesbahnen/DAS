import 'package:sfera/src/model/network_specific_area.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/taf_tap_location.dart';

class SpAreas extends SferaXmlElement {
  static const String elementType = 'SP_Areas';
  static const String _nonStandardTrackEquipmentName = 'nonStandardTrackEquipment';
  static const String _tramAreaName = 'tramArea';

  SpAreas({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TafTapLocation> get tafTapLocations => children.whereType<TafTapLocation>();

  Iterable<NetworkSpecificArea> get nonStandardTrackEquipments =>
      children.whereType<NetworkSpecificArea>().where((it) => it.groupName == _nonStandardTrackEquipmentName);

  Iterable<NetworkSpecificArea> get tramAreas =>
      children.whereType<NetworkSpecificArea>().where((it) => it.groupName == _tramAreaName);
}
