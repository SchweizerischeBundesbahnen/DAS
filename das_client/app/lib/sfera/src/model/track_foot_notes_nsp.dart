import 'package:app/sfera/src/model/network_specific_point.dart';
import 'package:app/sfera/src/model/xml_track_foot_notes.dart';

class TrackFootNotesNsp extends NetworkSpecificPoint {
  static const String elementName = 'trackFootNotes';

  TrackFootNotesNsp({super.type, super.attributes, super.children, super.value});

  XmlTrackFootNotes get xmlTrackFootNotes => parameters.whereType<XmlTrackFootNotes>().first;

  @override
  bool validate() {
    return validateHasChildOfType<XmlTrackFootNotes>() && super.validate();
  }
}
