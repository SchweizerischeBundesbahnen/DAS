import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/sp_zone.dart';

class SegmentProfileList extends SferaXmlElement {
  static const String elementType = "SegmentProfileList";

  SegmentProfileList({super.type = elementType, super.attributes, super.children, super.value});

  String get spId => attributes["SP_ID"]!;

  String get versionMajor => attributes["SP_VersionMajor"]!;

  String get versionMinor => attributes["SP_VersionMinor"]!;

  SpZone get spZone => children.whereType<SpZone>().first;

  @override
  bool validate() {
    return validateHasAttribute("SP_ID") &&
        validateHasAttribute("SP_VersionMajor") &&
        validateHasAttribute("SP_VersionMinor") &&
        validateHasChildOfType<SpZone>() &&
        super.validate();
  }
}
