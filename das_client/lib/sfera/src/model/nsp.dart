import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

abstract class Nsp extends SferaXmlElement {
  static const String elementType = 'NSP';

  Nsp({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes['name']!;

  Iterable<NetworkSpecificParameter> get parameters => children.whereType<NetworkSpecificParameter>();

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasChildOfType<NetworkSpecificParameter>() && super.validate();
  }
}
