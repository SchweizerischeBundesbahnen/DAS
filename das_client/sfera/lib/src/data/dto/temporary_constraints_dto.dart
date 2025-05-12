import 'package:sfera/src/data/dto/additional_speed_restriction_dto.dart';
import 'package:sfera/src/data/dto/enums/temporary_constraint_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraint_reason_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class TemporaryConstraintsDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'TemporaryConstraints';

  TemporaryConstraintsDto({super.type = elementType, super.attributes, super.children, super.value});

  DateTime? get startTime => ParseUtils.tryParseDateTime(attributes['startTime']);

  DateTime? get endTime => ParseUtils.tryParseDateTime(attributes['endTime']);

  TemporaryConstraintTypeDto get temporaryConstraintType =>
      XmlEnum.valueOf(TemporaryConstraintTypeDto.values, attributes['temporaryConstraintType']!)!;

  Iterable<TemporaryConstraintReasonDto> get temporaryConstraintReasons => children.whereType<TemporaryConstraintReasonDto>();

  AdditionalSpeedRestrictionDto? get additionalSpeedRestriction =>
      children.whereType<AdditionalSpeedRestrictionDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('temporaryConstraintType') && super.validate();
  }
}
