import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class SignalId extends SferaXmlElement {
  static const String elementType = 'Signal_ID';

  SignalId({super.type = elementType, super.attributes, super.children, super.value});

  String get physicalId => attributes['signal_ID_Physical']!;

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttribute('signal_ID_Physical') && validateHasAttributeDouble('location') && super.validate();
  }
}
