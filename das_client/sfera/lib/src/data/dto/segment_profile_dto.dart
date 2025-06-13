import 'package:sfera/src/data/dto/enums/sp_status_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/sp_areas_dto.dart';
import 'package:sfera/src/data/dto/sp_characteristics_dto.dart';
import 'package:sfera/src/data/dto/sp_context_information_dto.dart';
import 'package:sfera/src/data/dto/sp_points_dto.dart';
import 'package:sfera/src/data/dto/sp_zone_dto.dart';

class SegmentProfileDto extends SferaXmlElementDto {
  static const String elementType = 'SegmentProfile';

  SegmentProfileDto({super.type = elementType, super.attributes, super.children, super.value});

  String get versionMajor => attributes['SP_VersionMajor']!;

  String get versionMinor => attributes['SP_VersionMinor']!;

  String get length => attributes['SP_Length']!;

  String get id => attributes['SP_ID']!;

  SpStatusDto get status =>
      XmlEnum.valueOf<SpStatusDto>(SpStatusDto.values, attributes['SP_Status']) ?? SpStatusDto.valid;

  SpZoneDto? get zone => children.whereType<SpZoneDto>().firstOrNull;

  SpPointsDto? get points => children.whereType<SpPointsDto>().firstOrNull;

  SpContextInformationDto? get contextInformation => children.whereType<SpContextInformationDto>().firstOrNull;

  SpAreasDto? get areas => children.whereType<SpAreasDto>().firstOrNull;

  SpCharacteristicsDto? get characteristics => children.whereType<SpCharacteristicsDto>().firstOrNull;

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

extension SegmentProfileListExtension on Iterable<SegmentProfileDto> {
  SegmentProfileDto firstMatch(SegmentProfileReferenceDto segmentProfileReference) {
    return where(
      (it) =>
          it.id == segmentProfileReference.spId &&
          it.versionMajor == segmentProfileReference.versionMajor &&
          it.versionMinor == segmentProfileReference.versionMinor,
    ).first;
  }
}
