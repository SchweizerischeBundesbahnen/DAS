import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/timing_point_reference.dart';

class TimingPointConstraints extends SferaXmlElement {
  static const String elementType = 'TimingPointConstraints';

  TimingPointConstraints({super.type = elementType, super.attributes, super.children, super.value});

  TimingPointReference get timingPointReference => children.whereType<TimingPointReference>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TimingPointReference>() && super.validate();
  }
}