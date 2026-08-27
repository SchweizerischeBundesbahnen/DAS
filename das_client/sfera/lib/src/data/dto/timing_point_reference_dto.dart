import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/tp_id_reference_dto.dart';

class TimingPointReferenceDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'TimingPointReference';

  TpIdReferenceDto get tpIdReference => children.whereType<TpIdReferenceDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TpIdReferenceDto>() && super.validate();
  }
}
