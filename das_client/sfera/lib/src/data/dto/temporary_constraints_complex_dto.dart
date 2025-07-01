import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class TemporaryConstraintsComplexDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'TemporaryConstraints_ComplexType';

  TemporaryConstraintsComplexDto({super.type = elementType, super.attributes, super.children, super.value});

  DateTime? get startTime => ParseUtils.tryParseDateTime(attributes['startTime']);

  DateTime? get endTime => ParseUtils.tryParseDateTime(attributes['endTime']);
}
