import 'package:app/sfera/src/model/additional_speed_restriction.dart';
import 'package:app/sfera/src/model/enums/temporary_constraint_type.dart';
import 'package:app/sfera/src/model/enums/xml_enum.dart';
import 'package:app/sfera/src/model/sfera_segment_xml_element.dart';
import 'package:app/util/util.dart';

class TemporaryConstraints extends SferaSegmentXmlElement {
  static const String elementType = 'TemporaryConstraints';

  TemporaryConstraints({super.type = elementType, super.attributes, super.children, super.value});

  DateTime? get startTime => Util.tryParseDateTime(attributes['startTime']);

  DateTime? get endTime => Util.tryParseDateTime(attributes['endTime']);

  TemporaryConstraintType get temporaryConstraintType =>
      XmlEnum.valueOf(TemporaryConstraintType.values, attributes['temporaryConstraintType']!)!;

  AdditionalSpeedRestriction? get additionalSpeedRestriction =>
      children.whereType<AdditionalSpeedRestriction>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('temporaryConstraintType') && super.validate();
  }
}
