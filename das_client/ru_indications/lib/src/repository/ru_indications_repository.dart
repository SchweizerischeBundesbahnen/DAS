import 'package:ru_indications/src/model/ru_indication.dart';

abstract class RuIndicationsRepository {
  const RuIndicationsRepository._();

  /// Fetches RU indication matches for the given parameters.
  Future<List<RuIndication>> fetchRuIndications({
    required String company,
    required int trainNumber,
    required DateTime startDate,
    required List<String> tafTapLocationReferences,
  });
}
