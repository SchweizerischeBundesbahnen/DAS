import 'package:das_client/model/sfera/sfera_xml_element.dart';

class TpIdReference extends SferaXmlElement {
  static const String elementType = 'TP_ID_Reference';

  TpIdReference({super.type = elementType, super.attributes, super.children, super.value});

  String get tpId => attributes['TP_ID']!;

  @override
  bool validate() {
    return validateHasAttribute('TP_ID') && super.validate();
  }
}
