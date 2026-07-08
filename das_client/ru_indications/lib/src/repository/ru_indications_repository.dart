import 'package:core_data/component.dart';
import 'package:ru_indications/src/model/ru_indication.dart';

abstract class RuIndicationsRepository {
  const RuIndicationsRepository._();

  /// Fetches RU indication matches for the given parameters with automatic retry.
  /// Emits exactly one value once the fetch succeeds, then closes.
  /// The stream is automatically cancelled when the subscriber unsubscribes.
  ///
  /// [locationReferences] consists of key: locationCode, value: order in journey
  Stream<List<RuIndication>> fetchRuIndications({
    required TrainIdentification trainIdentification,
    required Map<String, int> locationReferences,
  });
}
