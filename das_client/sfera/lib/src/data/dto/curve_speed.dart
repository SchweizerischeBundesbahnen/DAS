import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/speeds.dart';

class CurveSpeed extends SferaXmlElement {
  static const String elementType = 'curveSpeed';

  CurveSpeed({super.type = elementType, super.attributes, super.children, super.value});

  Speeds? get speeds => children.whereType<Speeds>().firstOrNull;

  String? get text => attributes['text'];

  String? get comment => attributes['comment'];
}
