import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/nsp_xml_element.dart';
import 'package:sfera/src/data/dto/track_foot_notes.dart';

class XmlTrackFootNotes extends NetworkSpecificParameter with NspXmlElement<TrackFootNotes> {
  static const String elementName = 'xmlTrackFootNotes';

  XmlTrackFootNotes({super.attributes, super.children, super.value});
}
