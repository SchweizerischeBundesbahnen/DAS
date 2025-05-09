import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/xml_track_foot_notes_dto.dart';

class TrackFootNotesNspDto extends NetworkSpecificPointDto {
  static const String elementName = 'trackFootNotes';

  TrackFootNotesNspDto({super.type, super.attributes, super.children, super.value});

  XmlTrackFootNotesDto get xmlTrackFootNotes => parameters.whereType<XmlTrackFootNotesDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlTrackFootNotesDto>() && super.validate();
  }
}
