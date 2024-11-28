import 'package:das_client/sfera/src/model/network_specific_area.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';

class SpAreas extends SferaXmlElement {
  static const String elementType = 'SP_Areas';
  static const String _nonStandardTrackEquipmentName = 'nonStandardTrackEquipment';

  SpAreas({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TafTapLocation> get tafTapLocations => children.whereType<TafTapLocation>();

  Iterable<NetworkSpecificArea> get nonStandardTrackEquipments =>
      children.whereType<NetworkSpecificArea>().where((it) => it.name == _nonStandardTrackEquipmentName);
}
