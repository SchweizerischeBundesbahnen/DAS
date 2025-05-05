import 'package:sfera/src/model/balise.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';

class BaliseGroup extends SferaXmlElement {
  static const String elementType = 'BaliseGroup';

  BaliseGroup({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Balise> get balise => children.whereType<Balise>();
}
