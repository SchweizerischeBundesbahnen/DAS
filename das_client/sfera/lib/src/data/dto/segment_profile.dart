import 'package:sfera/src/data/dto/enums/sp_status.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/segment_profile_list.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/sp_areas.dart';
import 'package:sfera/src/data/dto/sp_characteristics.dart';
import 'package:sfera/src/data/dto/sp_context_information.dart';
import 'package:sfera/src/data/dto/sp_points.dart';
import 'package:sfera/src/data/dto/sp_zone.dart';

class SegmentProfile extends SferaXmlElement {
  static const String elementType = 'SegmentProfile';

  SegmentProfile({super.type = elementType, super.attributes, super.children, super.value});

  String get versionMajor => attributes['SP_VersionMajor']!;

  String get versionMinor => attributes['SP_VersionMinor']!;

  String get length => attributes['SP_Length']!;

  String get id => attributes['SP_ID']!;

  SpStatus get status => XmlEnum.valueOf<SpStatus>(SpStatus.values, attributes['SP_Status']) ?? SpStatus.valid;

  SpZone? get zone => children.whereType<SpZone>().firstOrNull;

  SpPoints? get points => children.whereType<SpPoints>().firstOrNull;

  SpContextInformation? get contextInformation => children.whereType<SpContextInformation>().firstOrNull;

  SpAreas? get areas => children.whereType<SpAreas>().firstOrNull;

  SpCharacteristics? get characteristics => children.whereType<SpCharacteristics>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('SP_VersionMajor') &&
        validateHasAttribute('SP_VersionMinor') &&
        validateHasAttribute('SP_Length') &&
        validateHasAttribute('SP_ID') &&
        super.validate();
  }
}

// extensions

extension SegmentProfileListExtension on Iterable<SegmentProfile> {
  SegmentProfile firstMatch(SegmentProfileReference segmentProfileReference) {
    return where((it) =>
        it.id == segmentProfileReference.spId &&
        it.versionMajor == segmentProfileReference.versionMajor &&
        it.versionMinor == segmentProfileReference.versionMinor).first;
  }
}
