import 'package:sfera/src/data/dto/enums/temporary_constraint_type.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/sp_zone.dart';
import 'package:sfera/src/data/dto/temporary_constraints.dart';
import 'package:sfera/src/data/dto/timing_point_constraints.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref.dart';

class SegmentProfileReference extends SferaXmlElement {
  static const String elementType = 'SegmentProfileReference';

  SegmentProfileReference({super.type = elementType, super.attributes, super.children, super.value});

  String get spId => attributes['SP_ID']!;

  String get versionMajor => attributes['SP_VersionMajor']!;

  String get versionMinor => attributes['SP_VersionMinor']!;

  SpZone get spZone => children.whereType<SpZone>().first;

  Iterable<TimingPointConstraints> get timingPointsConstraints => children.whereType<TimingPointConstraints>();

  Iterable<TrainCharacteristicsRef> get trainCharacteristicsRef => children.whereType<TrainCharacteristicsRef>();

  Iterable<TemporaryConstraints> get asrTemporaryConstrains => children
      .whereType<TemporaryConstraints>()
      .where((it) => it.temporaryConstraintType == TemporaryConstraintType.asr);

  @override
  bool validate() {
    return validateHasAttribute('SP_ID') &&
        validateHasAttribute('SP_VersionMajor') &&
        validateHasAttribute('SP_VersionMinor') &&
        validateHasChildOfType<SpZone>() &&
        super.validate();
  }
}
