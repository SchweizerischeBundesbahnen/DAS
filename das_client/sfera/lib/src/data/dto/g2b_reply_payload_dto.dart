import 'package:sfera/src/data/dto/g2b_message_response.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';

class G2bReplyPayloadDto extends SferaXmlElementDto {
  static const String elementType = 'G2B_ReplyPayload';

  G2bReplyPayloadDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<JourneyProfileDto> get journeyProfiles => children.whereType<JourneyProfileDto>();

  Iterable<SegmentProfileDto> get segmentProfiles => children.whereType<SegmentProfileDto>();

  Iterable<TrainCharacteristicsDto> get trainCharacteristics => children.whereType<TrainCharacteristicsDto>();

  Iterable<RelatedTrainInformationDto> get relatedTrainInformation => children.whereType<RelatedTrainInformationDto>();

  G2bMessageResponseDto? get messageResponse => children.whereType<G2bMessageResponseDto>().firstOrNull;
}
