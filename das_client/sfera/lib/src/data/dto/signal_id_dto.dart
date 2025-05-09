import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SignalIdDto extends SferaXmlElementDto {
  static const String elementType = 'Signal_ID';

  SignalIdDto({super.type = elementType, super.attributes, super.children, super.value});

  String get physicalId => attributes['signal_ID_Physical']!;

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttribute('signal_ID_Physical') && validateHasAttributeDouble('location') && super.validate();
  }
}
