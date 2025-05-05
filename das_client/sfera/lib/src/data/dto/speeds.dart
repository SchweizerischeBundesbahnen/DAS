import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/velocity.dart';

class Speeds extends SferaXmlElement {
  static const String elementType = 'speeds';

  Speeds({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Velocity> get velocities => children.whereType<Velocity>();
}
