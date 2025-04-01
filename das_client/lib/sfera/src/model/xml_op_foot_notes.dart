import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/nsp_xml_element.dart';
import 'package:das_client/sfera/src/model/op_foot_notes.dart';

class XmlOpFootNotes extends NetworkSpecificParameter with NspXmlElement<OpFootNotes> {
  static const String elementName = 'xmlOPFootNotes';

  XmlOpFootNotes({super.attributes, super.children, super.value});
}
