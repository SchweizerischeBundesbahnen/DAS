import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TpIdReferenceDto extends SferaXmlElementDto {
  static const String elementType = 'TP_ID_Reference';

  TpIdReferenceDto({super.type = elementType, super.attributes, super.children, super.value});

  String get tpId => attributes['TP_ID']!;

  @override
  bool validate() {
    return validateHasAttribute('TP_ID') && super.validate();
  }
}
