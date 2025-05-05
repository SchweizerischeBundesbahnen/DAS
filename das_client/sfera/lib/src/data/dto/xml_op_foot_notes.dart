import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/nsp_xml_element.dart';
import 'package:sfera/src/data/dto/op_foot_notes.dart';

class XmlOpFootNotes extends NetworkSpecificParameter with NspXmlElement<OpFootNotes> {
  static const String elementName = 'xmlOPFootNotes';

  XmlOpFootNotes({super.attributes, super.children, super.value});
}
