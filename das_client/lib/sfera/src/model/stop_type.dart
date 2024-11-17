import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class StopType extends SferaXmlElement {
  static const String elementType = 'StopType';

  StopType({super.type = elementType, super.attributes, super.children, super.value});

  String get stopTypePurpose => attributes['stopTypePurpose']!;

  String? get stopTypeDetails => attributes['stopTypeDetails'];

  bool? get plannedStop => bool.tryParse(attributes['plannedStop'] ?? '');

  bool? get mandatoryStop => bool.tryParse(attributes['mandatoryStop'] ?? '');

  @override
  bool validate() {
    return validateHasAttribute('stopTypePurpose') && super.validate();
  }
}
