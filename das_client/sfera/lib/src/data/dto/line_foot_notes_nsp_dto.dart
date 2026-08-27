import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_line_foot_notes_dto.dart';

class LineFootNotesNspDto({super.type, super.attributes, super.children, super.value}) extends TafTapLocationNspDto {
  static const String groupNameValue = 'lineFootNotes';

  XmlLineFootNotesDto get xmlLineFootNotes => parameters.whereType<XmlLineFootNotesDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlLineFootNotesDto>() && super.validate();
  }
}
