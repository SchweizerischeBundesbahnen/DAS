import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class NetworkSpecificPoint extends SferaXmlElement {
  static const String elementType = 'NetworkSpecificPoint';

  NetworkSpecificPoint({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes['name']!;

  double get location => double.parse(attributes['location']!);

  int get identifier => int.parse(attributes['identifier']!);

  Iterable<NetworkSpecificParameter> get networkSpecificParameters => children.whereType<NetworkSpecificParameter>();

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttributeDouble('location') && validateHasAttributeInt('identifier') && super.validate();
  }
}
