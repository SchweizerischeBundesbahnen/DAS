import 'package:das_client/model/sfera/sfera_xml_element.dart';

class StoppingPointInformation extends SferaXmlElement {
  static const String elementType = "StoppingPointInformation";

  StoppingPointInformation({super.type = elementType, super.attributes, super.children, super.value});

  String get departureTime => attributes["departureTime"]!;

  @override
  bool validate() {
    return validateHasAttribute("departureTime") && super.validate();
  }
}
