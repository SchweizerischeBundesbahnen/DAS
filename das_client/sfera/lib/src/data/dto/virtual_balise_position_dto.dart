import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class VirtualBalisePositionDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'VirtualBalisePosition';

  String get latitude => attributes['latitude']!;

  String get longitude => attributes['longitude']!;

  String? get altitude => attributes['altitude']!;

  @override
  bool validate() {
    return validateHasAttribute('latitude') && validateHasAttribute('longitude') && super.validate();
  }
}
