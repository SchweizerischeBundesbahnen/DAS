import 'package:das_client/sfera/src/model/contact.dart';
import 'package:das_client/sfera/src/model/sfera_segment_xml_element.dart';

class SferaContactList extends SferaSegmentXmlElement {
  static const String elementType = 'ContactList';

  SferaContactList({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<Contact> get contacts => children.whereType<Contact>();

  @override
  bool validate() => super.validate() && validateHasChildOfType<Contact>();
}
