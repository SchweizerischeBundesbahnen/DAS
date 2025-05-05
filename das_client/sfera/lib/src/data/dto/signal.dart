import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/signal_function.dart';
import 'package:sfera/src/data/dto/signal_id.dart';
import 'package:sfera/src/data/dto/signal_physical_characteristics.dart';

class Signal extends SferaXmlElement {
  static const String elementType = 'Signal';

  Signal({super.type = elementType, super.attributes, super.children, super.value});

  SignalId get id => children.whereType<SignalId>().first;

  SignalPhysicalCharacteristics? get physicalCharacteristics =>
      children.whereType<SignalPhysicalCharacteristics>().firstOrNull;

  Iterable<SignalFunction> get functions => children.whereType<SignalFunction>();

  @override
  bool validate() {
    return validateHasChildOfType<SignalId>() && super.validate();
  }
}
