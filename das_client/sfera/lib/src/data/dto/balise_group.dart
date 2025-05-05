import 'package:sfera/src/data/dto/balise.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class BaliseGroup extends SferaXmlElement {
  static const String elementType = 'BaliseGroup';

  BaliseGroup({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Balise> get balise => children.whereType<Balise>();
}
