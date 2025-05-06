import 'package:sfera/src/data/dto/line_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';

class XmlLineFootNotesDto extends NetworkSpecificParameterDto with NspXmlElementDto<LineFootNotesDto> {
  static const String elementName = 'xmlLineFootNotes';

  XmlLineFootNotesDto({super.attributes, super.children, super.value});
}
