import 'package:app/sfera/src/model/line_foot_notes.dart';
import 'package:app/sfera/src/model/network_specific_parameter.dart';
import 'package:app/sfera/src/model/nsp_xml_element.dart';

class XmlLineFootNotes extends NetworkSpecificParameter with NspXmlElement<LineFootNotes> {
  static const String elementName = 'xmlLineFootNotes';

  XmlLineFootNotes({super.attributes, super.children, super.value});
}
