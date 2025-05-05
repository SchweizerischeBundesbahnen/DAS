import 'package:sfera/src/model/sfera_segment_xml_element.dart';

class LevelCrossingArea extends SferaSegmentXmlElement {
  static const String elementType = 'LevelCrossingArea';

  LevelCrossingArea({super.type = elementType, super.attributes, super.children, super.value});

  @override
  double get startLocation => super.startLocation!;

  @override
  bool validate() {
    return validateHasAttributeDouble('startLocation') && super.validate();
  }
}
