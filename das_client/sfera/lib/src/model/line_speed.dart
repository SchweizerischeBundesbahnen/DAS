import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/speeds.dart';
import 'package:sfera/src/model/velocity.dart';

class LineSpeed extends SferaXmlElement {
  static const String elementType = 'lineSpeed';

  LineSpeed({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Velocity> get velocities => children.whereType<Velocity>();

  Speeds? get speeds => children.whereType<Speeds>().firstOrNull;

  String? get text => attributes['text'];
}
