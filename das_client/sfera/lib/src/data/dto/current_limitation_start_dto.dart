import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class CurrentLimitationStartDto extends SferaXmlElementDto {
  static const String elementType = 'CurrentLimitationStart';

  CurrentLimitationStartDto({super.type = elementType, super.attributes, super.children, super.value});

  String get maxCurValue => attributes['maxCurValue']!;

  @override
  bool validate() {
    return validateHasAttribute('maxCurValue') && super.validate();
  }
}
