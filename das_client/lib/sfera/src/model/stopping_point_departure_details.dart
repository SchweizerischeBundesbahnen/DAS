import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class StoppingPointDepartureDetails extends SferaXmlElement {
  static const String elementType = 'StoppingPointDepartureDetails';

  StoppingPointDepartureDetails({super.type = elementType, super.attributes, super.children, super.value});

  DateTime get departureTime => DateTime.parse(attributes['departureTime']!);

  @override
  bool validate() {
    return validateHasAttribute('departureTime') && super.validate();
  }
}
