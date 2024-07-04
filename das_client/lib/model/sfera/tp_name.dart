import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class TpName extends SferaXmlElement {
  static const String elementType = "TP_Name";

  TpName({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes["name"]!;

  @override
  bool validate() {
    return validateHasAttribute("name") && super.validate();
  }
}
