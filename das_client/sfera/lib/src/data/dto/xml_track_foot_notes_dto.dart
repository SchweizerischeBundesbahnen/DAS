import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/track_foot_notes_dto.dart';

class XmlTrackFootNotesDto extends NetworkSpecificParameterDto with NspXmlElementDto<TrackFootNotesDto> {
  static const String elementName = 'xmlTrackFootNotes';

  XmlTrackFootNotesDto({super.attributes, super.children, super.value});
}
