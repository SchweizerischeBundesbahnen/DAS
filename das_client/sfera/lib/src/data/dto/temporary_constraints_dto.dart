import 'package:sfera/src/data/dto/additional_speed_restriction_dto.dart';
import 'package:sfera/src/data/dto/enums/temporary_constraint_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/parallel_asr_constraint_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraint_reason_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_complex_dto.dart';

class TemporaryConstraintsDto extends TemporaryConstraintsComplexDto {
  static const String elementType = 'TemporaryConstraints';

  TemporaryConstraintsDto({super.type = elementType, super.attributes, super.children, super.value});

  TemporaryConstraintTypeDto get temporaryConstraintType =>
      XmlEnum.valueOf(TemporaryConstraintTypeDto.values, attributes['temporaryConstraintType']!)!;

  Iterable<TemporaryConstraintReasonDto> get temporaryConstraintReasons =>
      children.whereType<TemporaryConstraintReasonDto>();

  AdditionalSpeedRestrictionDto? get additionalSpeedRestriction =>
      children.whereType<AdditionalSpeedRestrictionDto>().firstOrNull;

  ParallelAsrConstraintDto? get parallelAsrConstraintDto => children.whereType<ParallelAsrConstraintDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('temporaryConstraintType') && super.validate();
  }
}
