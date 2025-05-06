import 'package:sfera/src/data/dto/enums/start_end_qualifier_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:app/util/util.dart';

class SferaSegmentXmlElementDto extends SferaXmlElementDto {
  SferaSegmentXmlElementDto({required super.type, super.attributes, super.children, super.value});

  StartEndQualifierDto get startEndQualifier =>
      XmlEnum.valueOf(StartEndQualifierDto.values, attributes['startEndQualifier']!)!;

  double? get startLocation => Util.tryParseDouble(attributes['startLocation']);

  double? get endLocation => Util.tryParseDouble(attributes['endLocation']);

  @override
  bool validate() {
    return validateHasAttribute('startEndQualifier') && super.validate();
  }
}
