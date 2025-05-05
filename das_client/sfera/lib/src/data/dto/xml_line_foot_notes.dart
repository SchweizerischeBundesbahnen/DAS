import 'package:sfera/src/data/dto/line_foot_notes.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/nsp_xml_element.dart';

class XmlLineFootNotes extends NetworkSpecificParameter with NspXmlElement<LineFootNotes> {
  static const String elementName = 'xmlLineFootNotes';

  XmlLineFootNotes({super.attributes, super.children, super.value});
}
