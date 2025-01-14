import 'package:das_client/sfera/src/model/network_specific_point.dart';
import 'package:das_client/sfera/src/model/xml_new_line_speed.dart';

class NewLineSpeedNetworkSpecificPoint extends NetworkSpecificPoint {
  static const String elementName = 'newLineSpeed';

  NewLineSpeedNetworkSpecificPoint({super.type, super.attributes, super.children, super.value});

  XmlNewLineSpeed get xmlNewLineSpeed => parameters.whereType<XmlNewLineSpeed>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlNewLineSpeed>() && super.validate();
  }
}
