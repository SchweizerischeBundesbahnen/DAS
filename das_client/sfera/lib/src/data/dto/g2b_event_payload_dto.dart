import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class G2bEventPayloadDto extends SferaXmlElementDto {
  static const String elementType = 'G2B_EventPayload';

  G2bEventPayloadDto({super.type = elementType, super.attributes, super.children, super.value});

  RelatedTrainInformationDto? get relatedTrainInformation =>
      children.whereType<RelatedTrainInformationDto>().firstOrNull;

  Iterable<JourneyProfileDto> get journeyProfiles => children.whereType<JourneyProfileDto>();

  NetworkSpecificEventDto? get networkSpecificEvent => children.whereType<NetworkSpecificEventDto>().firstOrNull;
}
