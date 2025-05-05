import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class TeltsiPrimaryLocationName extends SferaXmlElement {
  static const String elementType = 'teltsi_PrimaryLocationName';

  TeltsiPrimaryLocationName({
    super.type = elementType,
    super.attributes,
    super.children,
    super.value,
  });
}
