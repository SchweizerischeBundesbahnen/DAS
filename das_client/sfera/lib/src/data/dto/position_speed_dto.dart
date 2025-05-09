import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class PositionSpeedDto extends SferaXmlElementDto {
  static const String elementType = 'PositionSpeed';

  PositionSpeedDto({super.type = elementType, super.attributes, super.children, super.value});

  String get spId => attributes['SP_ID']!;

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttribute('SP_ID') && validateHasAttributeDouble('location') && super.validate();
  }
}
