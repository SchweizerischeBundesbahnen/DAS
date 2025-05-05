import 'package:sfera/src/model/current_limitation.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';

class SpCharacteristics extends SferaXmlElement {
  static const String elementType = 'SP_Characteristics';

  SpCharacteristics({super.type = elementType, super.attributes, super.children, super.value});

  CurrentLimitation? get currentLimitation => children.whereType<CurrentLimitation>().firstOrNull;
}
