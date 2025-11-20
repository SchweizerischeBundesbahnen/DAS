import 'package:collection/collection.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/tc_features_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';

class TrainCharacteristicsDto extends SferaXmlElementDto {
  static const String elementType = 'TrainCharacteristics';

  TrainCharacteristicsDto({super.type = elementType, super.attributes, super.children, super.value});

  String get tcId => attributes['TC_ID']!;

  String get ruId => childrenWithType('TC_RU_ID').first.value!;

  String get versionMajor => attributes['TC_VersionMajor']!;

  String get versionMinor => attributes['TC_VersionMinor']!;

  TcFeaturesDto get tcFeatures => children.whereType<TcFeaturesDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<TcFeaturesDto>() &&
        validateHasAttribute('TC_ID') &&
        validateHasChild('TC_RU_ID') &&
        validateHasAttribute('TC_VersionMajor') &&
        validateHasAttribute('TC_VersionMinor') &&
        super.validate();
  }
}

extension TrainCharacteristicsDtoIterableExtension on Iterable<TrainCharacteristicsDto> {
  TrainCharacteristicsDto? firstWhereGivenOrNull(TrainCharacteristicsRefDto trainReference) => firstWhereOrNull(
    (it) =>
        it.tcId == trainReference.tcId &&
        it.ruId == trainReference.ruId &&
        it.versionMajor == trainReference.versionMajor &&
        it.versionMinor == trainReference.versionMinor,
  );
}
