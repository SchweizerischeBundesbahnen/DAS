import 'package:sfera/src/data/dto/enums/jp_status_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';

class JourneyProfileDto extends SferaXmlElementDto {
  static const String elementType = 'JourneyProfile';

  JourneyProfileDto({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentificationDto get trainIdentification => children.whereType<TrainIdentificationDto>().first;

  Iterable<SegmentProfileReferenceDto> get segmentProfileReferences => children.whereType<SegmentProfileReferenceDto>();

  Set<TrainCharacteristicsRefDto> get trainCharacteristicsRefSet => children
      .whereType<SegmentProfileReferenceDto>()
      .map((it) => it.trainCharacteristicsRef)
      .expand((it) => it)
      .toSet();

  JpStatusDto get status =>
      XmlEnum.valueOf<JpStatusDto>(JpStatusDto.values, attributes['JP_Status']) ?? JpStatusDto.valid;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentificationDto>() && super.validate();
  }
}
