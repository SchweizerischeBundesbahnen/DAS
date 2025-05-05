import 'package:sfera/src/model/contact.dart';
import 'package:sfera/src/model/sfera_segment_xml_element.dart';

class ContactList extends SferaSegmentXmlElement {
  static const String elementType = 'ContactList';

  ContactList({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Contact> get contacts => children.whereType<Contact>();

  @override
  bool validate() => super.validate() && validateHasChildOfType<Contact>();
}
