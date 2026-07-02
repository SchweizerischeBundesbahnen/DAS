import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:ru_indications/src/api/dto/ru_indication_location_dto.dart';
import 'package:ru_indications/src/api/ru_indications_api_service.dart';
import 'package:ru_indications/src/model/ru_indication.dart';
import 'package:ru_indications/src/repository/ru_indications_repository.dart';

final _log = Logger('RuIndicationsRepositoryImpl');

class RuIndicationsRepositoryImpl implements RuIndicationsRepository {
  RuIndicationsRepositoryImpl({required this._apiService});

  final RuIndicationsApiService _apiService;

  @override
  Future<List<RuIndication>> fetchRuIndications({
    required String company,
    required String trainNumber,
    required DateTime startDate,
    required Map<String, int> locationReferences,
  }) async {
    try {
      final sanitizedTrainNumber = _sanitizeTrainNumber(trainNumber);
      final response = await _apiService.matches(
        company: company,
        operationalTrainNumber: sanitizedTrainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      );
      final ruIndications = response.body.data.map((dto) => dto.toRuIndications(locationReferences)).flattened;
      _log.info(
        'Successfully fetched ${ruIndications.length} RU indications for $sanitizedTrainNumber ($company) on $startDate.',
      );
      return ruIndications.toList();
    } catch (e) {
      _log.severe('Failed to load RU indications for $trainNumber ($company) on $startDate.', e);
      return [];
    }
  }

  int _sanitizeTrainNumber(String trainNumber) {
    final digitsOnly = trainNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return int.parse(digitsOnly);
  }
}
