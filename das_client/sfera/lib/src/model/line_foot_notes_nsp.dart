import 'package:sfera/src/model/taf_tap_location_nsp.dart';
import 'package:sfera/src/model/xml_line_foot_notes.dart';

class LineFootNotesNsp extends TafTapLocationNsp {
  static const String elementName = 'lineFootNotes';

  LineFootNotesNsp({super.type, super.attributes, super.children, super.value});

  XmlLineFootNotes get xmlLineFootNotes => parameters.whereType<XmlLineFootNotes>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlLineFootNotes>() && super.validate();
  }
}
