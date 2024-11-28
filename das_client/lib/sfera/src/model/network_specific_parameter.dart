import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class NetworkSpecificParameter extends SferaXmlElement {
  static const String elementType = 'NetworkSpecificParameter';

  NetworkSpecificParameter({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes['name']!;

  String get nspValue => attributes['value']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('value') && super.validate();
  }
}

// extensions

extension NetworkSpecificParametersExtension on Iterable<NetworkSpecificParameter> {
  NetworkSpecificParameter? withName(String name) => where((it) => it.name == name).firstOrNull;
}
