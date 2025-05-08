import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TeltsiPrimaryLocationNameDto extends SferaXmlElementDto {
  static const String elementType = 'teltsi_PrimaryLocationName';

  TeltsiPrimaryLocationNameDto({
    super.type = elementType,
    super.attributes,
    super.children,
    super.value,
  });
}
