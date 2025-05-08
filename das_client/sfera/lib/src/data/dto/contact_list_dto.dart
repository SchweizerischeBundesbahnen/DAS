import 'package:sfera/src/data/dto/contact_dto.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';

class ContactListDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'ContactList';

  ContactListDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<ContactDto> get contacts => children.whereType<ContactDto>();

  @override
  bool validate() => super.validate() && validateHasChildOfType<ContactDto>();
}
