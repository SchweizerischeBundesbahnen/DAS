import 'package:app/sfera/src/model/sfera_xml_element.dart';

class SpZone extends SferaXmlElement {
  static const String elementType = 'SP_Zone';

  SpZone({super.type = elementType, super.attributes, super.children, super.value});

  String? get imId => childrenWithType('IM_ID').firstOrNull?.value;

  String? get nidC => childrenWithType('NID_C').firstOrNull?.value;

  @override
  bool validate() {
    return (validateHasChild('IM_ID') || validateHasChild('NID_C')) && super.validate();
  }
}
