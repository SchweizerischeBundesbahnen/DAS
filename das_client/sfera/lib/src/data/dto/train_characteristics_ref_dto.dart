import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TrainCharacteristicsRefDto extends SferaXmlElementDto {
  static const String elementType = 'TrainCharacteristicsRef';

  TrainCharacteristicsRefDto({super.type = elementType, super.attributes, super.children, super.value});

  String get tcId => attributes['TC_ID']!;

  String get ruId => childrenWithType('TC_RU_ID').first.value!;

  String get versionMajor => attributes['TC_VersionMajor']!;

  String get versionMinor => attributes['TC_VersionMinor']!;

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttribute('TC_ID') &&
        validateHasChild('TC_RU_ID') &&
        validateHasAttributeDouble('location') &&
        validateHasAttribute('TC_VersionMajor') &&
        validateHasAttribute('TC_VersionMinor') &&
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
