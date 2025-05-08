import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class StopTypeDto extends SferaXmlElementDto {
  static const String elementType = 'StopType';

  StopTypeDto({super.type = elementType, super.attributes, super.children, super.value});

  String get trainActivityType => childrenWithType('teltsi_TrainActivityType').first.value!;

  String? get stopTypeDetails => attributes['stopTypeDetails'];

  bool? get plannedStop => bool.tryParse(attributes['plannedStop'] ?? '');

  bool? get mandatoryStop => bool.tryParse(attributes['mandatoryStop'] ?? '');

  @override
  bool validate() {
    return validateHasChild('teltsi_TrainActivityType') && super.validate();
  }
}
