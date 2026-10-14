import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class TrainCharacteristicsRefDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'TrainCharacteristicsRef';

  String get tcId => attributes['TC_ID']!;

  String get ruId => childrenWithType('TC_RU_ID').first.value!;

  String get versionMajor => attributes['TC_VersionMajor']!;

  String get versionMinor => attributes['TC_VersionMinor'] ?? '0';

  double get location => ParseUtils.tryParseDouble(attributes['location']) ?? 0.0;

  @override
  bool validate() {
    return validateHasAttribute('TC_ID') &&
        validateHasChild('TC_RU_ID') &&
        validateHasAttribute('TC_VersionMajor') &&
        super.validate();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainCharacteristicsRefDto &&
        other.tcId == tcId &&
        other.versionMajor == versionMajor &&
        other.versionMinor == versionMinor &&
        other.ruId == ruId;
  }

  @override
  int get hashCode => tcId.hashCode ^ versionMajor.hashCode ^ versionMinor.hashCode ^ ruId.hashCode;

  @override
  String toString() {
    return 'TrainCharacteristicsRefDto{tcId: $tcId, versionMajor: $versionMajor, versionMinor: $versionMinor, ruId: $ruId}';
  }
}
