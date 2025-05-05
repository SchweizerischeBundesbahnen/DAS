import 'package:sfera/src/data/dto/taf_tap_location_nsp.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed.dart';

class NewLineSpeedTafTapLocation extends TafTapLocationNsp {
  static const String elementName = 'newLineSpeed';

  NewLineSpeedTafTapLocation({super.type, super.attributes, super.children, super.value});

  XmlNewLineSpeed get xmlNewLineSpeed => parameters.whereType<XmlNewLineSpeed>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlNewLineSpeed>() && super.validate();
  }
}
