import 'package:app/sfera/src/model/network_specific_parameter.dart';
import 'package:app/sfera/src/model/nsp_xml_element.dart';
import 'package:app/sfera/src/model/op_foot_notes.dart';

class XmlOpFootNotes extends NetworkSpecificParameter with NspXmlElement<OpFootNotes> {
  static const String elementName = 'xmlOPFootNotes';

  XmlOpFootNotes({super.attributes, super.children, super.value});
}
