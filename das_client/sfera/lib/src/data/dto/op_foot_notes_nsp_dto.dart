import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_op_foot_notes_dto.dart';

class OpFootNotesNspDto extends TafTapLocationNspDto {
  static const String groupNameValue = 'oPFootNotes';

  OpFootNotesNspDto({super.type, super.attributes, super.children, super.value});

  XmlOpFootNotesDto get xmlOpFootNotes => parameters.whereType<XmlOpFootNotesDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlOpFootNotesDto>() && super.validate();
  }
}
