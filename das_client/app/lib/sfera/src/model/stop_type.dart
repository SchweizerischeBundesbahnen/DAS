import 'package:app/sfera/src/model/sfera_xml_element.dart';

class StopType extends SferaXmlElement {
  static const String elementType = 'StopType';

  StopType({super.type = elementType, super.attributes, super.children, super.value});

  String get trainActivityType => childrenWithType('teltsi_TrainActivityType').first.value!;

  String? get stopTypeDetails => attributes['stopTypeDetails'];

  bool? get plannedStop => bool.tryParse(attributes['plannedStop'] ?? '');

  bool? get mandatoryStop => bool.tryParse(attributes['mandatoryStop'] ?? '');

  @override
  bool validate() {
    return validateHasChild('teltsi_TrainActivityType') && super.validate();
  }
}
