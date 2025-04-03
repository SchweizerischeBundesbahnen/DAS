import 'package:das_client/sfera/src/model/other_contact_type.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/util/util.dart';

class Contact extends SferaXmlElement {
  static const String elementType = 'Contact';

  Contact({super.type = elementType, super.attributes, super.children, super.value});

  bool get mainContact => Util.tryParseBool(attributes['mainContact']) ?? false;

  String? get contactRole => attributes['contactRole'];

  OtherContactType? get otherContactType => children.whereType<OtherContactType>().firstOrNull;

  @override
  bool validate() => validateHasChildOfType<OtherContactType>() && super.validate();
}
