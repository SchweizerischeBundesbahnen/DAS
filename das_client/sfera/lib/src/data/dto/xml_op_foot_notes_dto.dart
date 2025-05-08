import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/op_foot_notes_dto.dart';

class XmlOpFootNotesDto extends NetworkSpecificParameterDto with NspXmlElementDto<OpFootNotesDto> {
  static const String elementName = 'xmlOPFootNotes';

  XmlOpFootNotesDto({super.attributes, super.children, super.value});
}
