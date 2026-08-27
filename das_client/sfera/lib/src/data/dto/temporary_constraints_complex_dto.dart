import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class TemporaryConstraintsComplexDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaSegmentXmlElementDto {
  static const String elementType = 'TemporaryConstraints_ComplexType';

  DateTime? get startTime => ParseUtils.tryParseDateTime(attributes['startTime']);

  DateTime? get endTime => ParseUtils.tryParseDateTime(attributes['endTime']);
}
