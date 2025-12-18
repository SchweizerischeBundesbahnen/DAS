import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/g2b_error.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class G2bMessageResponseDto extends SferaXmlElementDto {
  static const String elementType = 'G2B_MessageResponse';

  G2bMessageResponseDto({super.type = elementType, super.attributes, super.children, super.value});

  G2bMessageResponseResult get result => XmlEnum.valueOf(G2bMessageResponseResult.values, attributes['result'])!;

  Iterable<G2bErrorDto> get errors => children.whereType<G2bErrorDto>();

  @override
  bool validate() {
    return validateHasAttributeInRange('result', XmlEnum.values(G2bMessageResponseResult.values)) && super.validate();
  }
}

enum G2bMessageResponseResult implements XmlEnum {
  ok(xmlValue: 'OK'),
  error(xmlValue: 'ERROR')
  ;

  const G2bMessageResponseResult({required this.xmlValue});

  @override
  final String xmlValue;
}
