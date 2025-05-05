import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/tc_features.dart';

class TrainCharacteristics extends SferaXmlElement {
  static const String elementType = 'TrainCharacteristics';

  TrainCharacteristics({super.type = elementType, super.attributes, super.children, super.value});

  String get tcId => attributes['TC_ID']!;

  String get ruId => childrenWithType('TC_RU_ID').first.value!;

  String get versionMajor => attributes['TC_VersionMajor']!;

  String get versionMinor => attributes['TC_VersionMinor']!;

  TcFeatures get tcFeatures => children.whereType<TcFeatures>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TcFeatures>() &&
        validateHasAttribute('TC_ID') &&
        validateHasChild('TC_RU_ID') &&
        validateHasAttribute('TC_VersionMajor') &&
        validateHasAttribute('TC_VersionMinor') &&
        super.validate();
  }
}
