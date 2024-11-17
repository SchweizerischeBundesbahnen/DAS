import 'package:das_client/sfera/sfera_component.dart';

class TimingPointReference extends SferaXmlElement {
  static const String elementType = 'TimingPointReference';

  TpIdReference get tpIdReference => children.whereType<TpIdReference>().first;

  TimingPointReference({super.type = elementType, super.attributes, super.children, super.value});

  @override
  bool validate() {
    return validateHasChildOfType<TpIdReference>() && super.validate();
  }
}
