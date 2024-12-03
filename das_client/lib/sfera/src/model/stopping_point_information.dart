import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/stop_type.dart';

class StoppingPointInformation extends SferaXmlElement {
  static const String elementType = 'StoppingPointInformation';

  StoppingPointInformation({super.type = elementType, super.attributes, super.children, super.value});

  DateTime get departureTime => DateTime.parse(attributes['departureTime']!);

  StopType? get stopType => children.whereType<StopType>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('departureTime') && super.validate();
  }
}
