import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SignalPhysicalCharacteristicsDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'SignalPhysicalCharacteristics';

  String get visualIdentifier => attributes['visualIdentifier']!;

  @override
  bool validate() {
    return validateHasAttribute('visualIdentifier') && super.validate();
  }
}
