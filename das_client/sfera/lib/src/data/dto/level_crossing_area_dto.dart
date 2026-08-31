import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';

class LevelCrossingAreaDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaSegmentXmlElementDto {
  static const String elementType = 'LevelCrossingArea';

  @override
  double get startLocation => super.startLocation!;

  @override
  bool validate() {
    return validateHasAttributeDouble('startLocation') && super.validate();
  }
}
