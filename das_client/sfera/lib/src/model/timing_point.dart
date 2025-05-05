import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/taf_tap_location_reference.dart';
import 'package:sfera/src/model/tp_name.dart';

class TimingPoint extends SferaXmlElement {
  static const String elementType = 'TimingPoint';

  TimingPoint({super.type = elementType, super.attributes, super.children, super.value});

  String get id => attributes['TP_ID']!;

  double get location => double.parse(attributes['location']!);

  Iterable<TpName> get names => children.whereType<TpName>();

  TafTapLocationReference? get locationReference => children.whereType<TafTapLocationReference>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('TP_ID') && validateHasAttributeDouble('location') && super.validate();
  }
}
