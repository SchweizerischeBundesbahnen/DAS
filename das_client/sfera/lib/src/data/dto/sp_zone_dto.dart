import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class SpZoneDto({super.type = elementType, super.attributes, super.children, super.value}) extends SferaXmlElementDto {
  static const String elementType = 'SP_Zone';

  String? get imId => childrenWithType('IM_ID').firstOrNull?.value;

  String? get nidC => childrenWithType('NID_C').firstOrNull?.value;

  @override
  bool validate() {
    return (validateHasChild('IM_ID') || validateHasChild('NID_C')) && super.validate();
  }
}
