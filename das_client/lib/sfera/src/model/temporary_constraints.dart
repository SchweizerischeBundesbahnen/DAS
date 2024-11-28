import 'package:das_client/sfera/src/model/additional_speed_restriction.dart';
import 'package:das_client/sfera/src/model/enums/start_end_qualifier.dart';
import 'package:das_client/sfera/src/model/enums/temporary_constraint_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class TemporaryConstraints extends SferaXmlElement {
  static const String elementType = 'TemporaryConstraints';

  TemporaryConstraints({super.type = elementType, super.attributes, super.children, super.value});

  StartEndQualifier get startEndQualifier =>
      XmlEnum.valueOf(StartEndQualifier.values, attributes['startEndQualifier']!)!;

  double? get startLocation =>
      attributes['startLocation'] != null ? double.tryParse(attributes['startLocation']!) : null;

  double? get endLocation => attributes['endLocation'] != null ? double.tryParse(attributes['endLocation']!) : null;

  DateTime? get startTime => attributes['startTime'] != null ? DateTime.tryParse(attributes['startTime']!) : null;

  DateTime? get endTime => attributes['endTime'] != null ? DateTime.tryParse(attributes['endTime']!) : null;

  TemporaryConstraintType get temporaryConstraintType =>
      XmlEnum.valueOf(TemporaryConstraintType.values, attributes['temporaryConstraintType']!)!;

  AdditionalSpeedRestriction? get additionalSpeedRestriction =>
      children.whereType<AdditionalSpeedRestriction>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('startEndQualifier') &&
        validateHasAttribute('temporaryConstraintType') &&
        super.validate();
  }
}
