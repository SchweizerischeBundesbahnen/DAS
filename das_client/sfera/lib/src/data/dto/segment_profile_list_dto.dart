import 'package:sfera/src/data/dto/jp_context_information_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/sp_zone_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_dto.dart';
import 'package:sfera/src/data/dto/timing_point_constraints_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';

class SegmentProfileReferenceDto extends SferaXmlElementDto {
  static const String elementType = 'SegmentProfileReference';

  SegmentProfileReferenceDto({super.type = elementType, super.attributes, super.children, super.value});

  String get spId => attributes['SP_ID']!;

  String get versionMajor => attributes['SP_VersionMajor']!;

  String get versionMinor => attributes['SP_VersionMinor']!;

  SpZoneDto get spZone => children.whereType<SpZoneDto>().first;

  Iterable<TimingPointConstraintsDto> get timingPointsConstraints => children.whereType<TimingPointConstraintsDto>();

  Iterable<TrainCharacteristicsRefDto> get trainCharacteristicsRef => children.whereType<TrainCharacteristicsRefDto>();

  Iterable<TemporaryConstraintsDto> get asrTemporaryConstraints =>
      children.whereType<TemporaryConstraintsDto>().where((it) => it.temporaryConstraintType == .asr);

  Iterable<TemporaryConstraintsDto> get advisedSpeedTemporaryConstraints =>
      children.whereType<TemporaryConstraintsDto>().where((it) => it.temporaryConstraintType == .advisedSpeed);

  JpContextInformationDto? get jpContextInformation => children.whereType<JpContextInformationDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('SP_ID') &&
        validateHasAttribute('SP_VersionMajor') &&
        validateHasAttribute('SP_VersionMinor') &&
        validateHasChildOfType<SpZoneDto>() &&
        super.validate();
  }
}
