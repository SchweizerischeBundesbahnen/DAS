import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/velocity.dart';

class Speeds extends SferaXmlElement {
  static const String elementType = 'speeds';

  Speeds({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Velocity> get velocities => children.whereType<Velocity>();
}
