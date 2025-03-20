import 'package:das_client/sfera/src/model/foot_note.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class LineFootNotes extends SferaXmlElement {
  static const String elementType = 'lineFootNotes';

  LineFootNotes({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<FootNote> get footNotes => children.whereType<FootNote>();
}
