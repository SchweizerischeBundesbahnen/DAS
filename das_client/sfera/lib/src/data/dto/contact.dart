import 'package:sfera/src/data/dto/other_contact_type.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:app/util/util.dart';

class Contact extends SferaXmlElement {
  static const String elementType = 'Contact';

  Contact({super.type = elementType, super.attributes, super.children, super.value});

  bool get mainContact => Util.tryParseBool(attributes['mainContact']) ?? false;

  String? get contactRole => attributes['contactRole'];

  OtherContactType? get otherContactType => children.whereType<OtherContactType>().firstOrNull;

  @override
  bool validate() => validateHasChildOfType<OtherContactType>() && super.validate();
}
