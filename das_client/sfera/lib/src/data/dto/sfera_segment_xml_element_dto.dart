import 'package:sfera/src/data/dto/enums/start_end_qualifier_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class SferaSegmentXmlElementDto extends SferaXmlElementDto {
  SferaSegmentXmlElementDto({required super.type, super.attributes, super.children, super.value});

  StartEndQualifierDto get startEndQualifier =>
      XmlEnum.valueOf(StartEndQualifierDto.values, attributes['startEndQualifier']!)!;

  double? get startLocation => ParseUtils.tryParseDouble(attributes['startLocation']);

  double? get endLocation => ParseUtils.tryParseDouble(attributes['endLocation']);

  @override
  bool validate() {
    return validateHasAttribute('startEndQualifier') && super.validate();
  }
}
