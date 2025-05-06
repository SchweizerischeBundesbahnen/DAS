import 'package:sfera/src/data/dto/other_contact_type_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:app/util/util.dart';

class ContactDto extends SferaXmlElementDto {
  static const String elementType = 'Contact';

  ContactDto({super.type = elementType, super.attributes, super.children, super.value});

  bool get mainContact => Util.tryParseBool(attributes['mainContact']) ?? false;

  String? get contactRole => attributes['contactRole'];

  OtherContactTypeDto? get otherContactType => children.whereType<OtherContactTypeDto>().firstOrNull;

  @override
  bool validate() => validateHasChildOfType<OtherContactTypeDto>() && super.validate();
}
