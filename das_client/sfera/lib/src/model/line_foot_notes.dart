import 'package:sfera/src/model/foot_note.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';

class LineFootNotes extends SferaXmlElement {
  static const String elementType = 'lineFootNotes';

  LineFootNotes({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<SferaFootNote> get footNotes => children.whereType<SferaFootNote>();
}
