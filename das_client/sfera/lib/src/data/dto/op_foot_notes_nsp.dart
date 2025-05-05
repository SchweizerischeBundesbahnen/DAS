import 'package:sfera/src/data/dto/taf_tap_location_nsp.dart';
import 'package:sfera/src/data/dto/xml_op_foot_notes.dart';

class OpFootNotesNsp extends TafTapLocationNsp {
  static const String elementName = 'oPFootNotes';

  OpFootNotesNsp({super.type, super.attributes, super.children, super.value});

  XmlOpFootNotes get xmlOpFootNotes => parameters.whereType<XmlOpFootNotes>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlOpFootNotes>() && super.validate();
  }
}
