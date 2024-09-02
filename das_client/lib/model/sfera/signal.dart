import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/signal_id.dart';

class Signal extends SferaXmlElement {
  static const String elementType = "Signal";

  Signal({super.type = elementType, super.attributes, super.children, super.value});

  SignalId get id => children.whereType<SignalId>().first;

  @override
  bool validate() {
    return validateHasChild("Signal_ID") && super.validate();
  }
}
