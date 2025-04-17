import 'package:das_client/sfera/src/model/foot_note.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class TrackFootNotes extends SferaXmlElement {
  static const String elementType = 'trackFootNotes';

  TrackFootNotes({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<SferaFootNote> get footNotes => children.whereType<SferaFootNote>();
}
