import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/timing_point_reference.dart';

class TimingPointConstraints extends SferaXmlElement {
  static const String elementType = 'TimingPointConstraints';

  TimingPointConstraints({super.type = elementType, super.attributes, super.children, super.value});

  TimingPointReference get timingPointReference => children.whereType<TimingPointReference>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TimingPointReference>() && super.validate();
  }
}
