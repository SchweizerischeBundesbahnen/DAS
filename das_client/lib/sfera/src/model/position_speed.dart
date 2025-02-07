import 'package:das_client/sfera/src/model/delay.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class PositionSpeed extends SferaXmlElement {
  static const String elementType = 'PositionSpeed';

  PositionSpeed({super.type = elementType, super.attributes, super.children, super.value});

  String get spId => attributes['SP_ID']!;

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttribute('SP_ID') && validateHasAttributeDouble('location') && super.validate();
  }
}
