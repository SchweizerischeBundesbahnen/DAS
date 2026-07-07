import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
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
    required TrainIdentification trainIdentification,
    required Map<String, int> locationReferences,
  }) async {
    final company = trainIdentification.ru.companyCode;
    final trainNumber = trainIdentification.sanitizedTrainNumber;
    final startDate = trainIdentification.operatingDay ?? trainIdentification.date;

    try {
      final response = await _apiService.matches(
        company: company,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      );
      final ruIndications = response.body.data.map((dto) => dto.toRuIndications(locationReferences)).flattened;
      _log.info(
        'Successfully fetched ${ruIndications.length} RU indications for $trainNumber ($company) on $startDate.',
      );
      return ruIndications.toList();
    } catch (e) {
      _log.severe('Failed to load RU indications for $trainNumber ($company) on $startDate.', e);
      rethrow;
    }
  }
}
