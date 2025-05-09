import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/virtual_balise_position_dto.dart';

class VirtualBaliseDto extends SferaXmlElementDto {
  static const String elementType = 'VirtualBalise';

  VirtualBaliseDto({super.type = elementType, super.attributes, super.children, super.value});

  VirtualBalisePositionDto get position => children.whereType<VirtualBalisePositionDto>().first;

  String get location => attributes['location']!;

  @override
  bool validate() {
    return validateHasAttribute('location') && validateHasChildOfType<VirtualBalisePositionDto>() && super.validate();
  }
}
