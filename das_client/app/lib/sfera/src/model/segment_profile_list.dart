import 'package:app/sfera/src/model/enums/temporary_constraint_type.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';
import 'package:app/sfera/src/model/sp_zone.dart';
import 'package:app/sfera/src/model/temporary_constraints.dart';
import 'package:app/sfera/src/model/timing_point_constraints.dart';
import 'package:app/sfera/src/model/train_characteristics_ref.dart';

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
