import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/tp_name.dart';

class TimingPoint extends SferaXmlElement {
  static const String elementType = 'TimingPoint';

  TimingPoint({super.type = elementType, super.attributes, super.children, super.value});

  String get id => attributes['TP_ID']!;

  String get location => attributes['location']!;

  Iterable<TpName> get names => children.whereType<TpName>();

  @override
  bool validate() {
    return validateHasAttribute('TP_ID') && validateHasAttribute('location') && super.validate();
  }
}
