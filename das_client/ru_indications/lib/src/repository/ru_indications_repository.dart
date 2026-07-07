import 'package:core_data/component.dart';
import 'package:ru_indications/src/model/ru_indication.dart';

abstract class RuIndicationsRepository {
  const RuIndicationsRepository._();

  /// Fetches RU indication matches for the given parameters.
  ///
  /// [locationReferences] consists of key: locationCode, value: order in journey
  Future<List<RuIndication>> fetchRuIndications({
    required TrainIdentification trainIdentification,
    required Map<String, int> locationReferences,
  });
}
