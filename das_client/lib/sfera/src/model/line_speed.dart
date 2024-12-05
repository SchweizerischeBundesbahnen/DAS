import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/speeds.dart';

class LineSpeed extends SferaXmlElement {
  static const String elementType = 'lineSpeed';

  LineSpeed({super.type = elementType, super.attributes, super.children, super.value});

  Speeds? get speeds => children.whereType<Speeds>().firstOrNull;

  String? get text => attributes['text'];
}
