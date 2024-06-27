import 'package:das_client/model/sfera/sfera_xml_element.dart';

class SegmentProfileList extends SferaXmlElement {
  static const String elementType = "SegmentProfileList";

  SegmentProfileList({required super.type, super.attributes, super.children, super.value});

  String get versionMajor => attributes["SP_VersionMajor"];
  String get versionMinor => attributes["SP_VersionMinor"];

  @override
  bool validate() {
    return validateHasAttribute("SP_VersionMajor") && validateHasAttribute("SP_VersionMinor") && super.validate();
  }
}
