import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/tp_name.dart';
import 'package:das_client/model/sfera/virtual_balise_position.dart';

class VirtualBalise extends SferaXmlElement {
  static const String elementType = "VirtualBalise";

  VirtualBalise({super.type = elementType, super.attributes, super.children, super.value});

  VirtualBalisePosition get position => children.whereType<VirtualBalisePosition>().first;

  String get location => attributes["location"]!;

  @override
  bool validate() {
    return validateHasAttribute("location") && validateHasChildOfType<VirtualBalisePosition>() && super.validate();
  }
}
