import 'package:sfera/src/data/dto/enums/jp_status_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/general_jp_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class JourneyProfileDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'JourneyProfile';

  factory create({
    required int version,
    required TrainIdentificationDto trainIdentification,
    required List<SegmentProfileReferenceDto> segmentProfileReferences,
    required GeneralJpInformationDto? generalJpInformation,
  }) {
    final request = JourneyProfileDto();
    request.attributes['JP_Version'] = version.toString();
    request.attributes['JP_Status'] = JpStatusDto.valid.xmlValue;
    request.children.add(trainIdentification);
    request.children.addAll(segmentProfileReferences);
    if (generalJpInformation != null) {
      request.children.add(generalJpInformation);
    }
    return request;
  }

  int get version => ParseUtils.tryParseInt(attributes['JP_Version']) ?? 0;

  TrainIdentificationDto get trainIdentification => children.whereType<TrainIdentificationDto>().first;

  Iterable<SegmentProfileReferenceDto> get segmentProfileReferences => children.whereType<SegmentProfileReferenceDto>();

  Set<TrainCharacteristicsRefDto> get trainCharacteristicsRefSet => children
      .whereType<SegmentProfileReferenceDto>()
      .map((it) => it.trainCharacteristicsRef)
      .expand((it) => it)
      .toSet();

  JpStatusDto get status =>
      XmlEnum.valueOf<JpStatusDto>(JpStatusDto.values, attributes['JP_Status']) ?? JpStatusDto.valid;

  GeneralJpInformationDto? get generalJpInformation => children.whereType<GeneralJpInformationDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentificationDto>() && super.validate();
  }
}
