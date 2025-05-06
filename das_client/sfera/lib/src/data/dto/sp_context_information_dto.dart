import 'package:sfera/src/data/dto/communication_network_dto.dart';
import 'package:sfera/src/data/dto/connection_track_dto.dart';
import 'package:sfera/src/data/dto/contact_list_dto.dart';
import 'package:sfera/src/data/dto/decisive_gradient_area_dto.dart';
import 'package:sfera/src/data/dto/kilometre_reference_point_dto.dart';
import 'package:sfera/src/data/dto/level_crossing_area_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SpContextInformationDto extends SferaXmlElementDto {
  static const String elementType = 'SP_ContextInformation';

  SpContextInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<KilometreReferencePointDto> get kilometreReferencePoints => children.whereType<KilometreReferencePointDto>();

  Iterable<ConnectionTrackDto> get connectionTracks => children.whereType<ConnectionTrackDto>();

  Iterable<CommunicationNetworkDto> get communicationNetworks => children.whereType<CommunicationNetworkDto>();

  Iterable<LevelCrossingAreaDto> get levelCrossings => children.whereType<LevelCrossingAreaDto>();

  Iterable<ContactListDto> get contactLists => children.whereType<ContactListDto>();

  Iterable<DecisiveGradientAreaDto> get decisiveGradientAreas => children.whereType<DecisiveGradientAreaDto>();
}
