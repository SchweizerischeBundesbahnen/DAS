import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';

class SpAreas extends SferaXmlElement {
  static const String elementType = 'SP_Areas';

  SpAreas({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<TafTapLocation> get tafTapLocations => children.whereType<TafTapLocation>();
}
