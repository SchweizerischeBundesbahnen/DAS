import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/sp_points.dart';
import 'package:das_client/sfera/src/model/sp_zone.dart';

class SegmentProfile extends SferaXmlElement {
  static const String elementType = 'SegmentProfile';

  SegmentProfile({super.type = elementType, super.attributes, super.children, super.value});

  String get versionMajor => attributes['SP_VersionMajor']!;

  String get versionMinor => attributes['SP_VersionMinor']!;

  String get length => attributes['SP_Length']!;

  String get id => attributes['SP_ID']!;

  SpZone? get zone => children.whereType<SpZone>().firstOrNull;

  SpPoints? get points => children.whereType<SpPoints>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('SP_VersionMajor') &&
        validateHasAttribute('SP_VersionMinor') &&
        validateHasAttribute('SP_Length') &&
        validateHasAttribute('SP_ID') &&
        super.validate();
  }
}
