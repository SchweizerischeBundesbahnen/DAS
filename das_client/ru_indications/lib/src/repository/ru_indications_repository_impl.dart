import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:ru_indications/src/api/dto/ru_indication_location_dto.dart';
import 'package:ru_indications/src/api/ru_indications_api_service.dart';
import 'package:ru_indications/src/model/ru_indication.dart';
import 'package:ru_indications/src/repository/ru_indications_repository.dart';

final _log = Logger('RuIndicationsRepositoryImpl');

class RuIndicationsRepositoryImpl implements RuIndicationsRepository {
  static const _defaultRetryDelaySeconds = 30;

  RuIndicationsRepositoryImpl({
    required this._apiService,
    this._retryDelaySeconds = _defaultRetryDelaySeconds,
  });

  final RuIndicationsApiService _apiService;
  final int _retryDelaySeconds;

  @override
  Stream<List<RuIndication>> fetchRuIndications({
    required TrainIdentification trainIdentification,
    required Map<String, int> locationReferences,
  }) {
    final controller = StreamController<List<RuIndication>>();

    // Stop retrying when the subscriber unsubscribes
    controller.onCancel = () {
      if (!controller.isClosed) controller.close();
    };

    _fetchWithRetry(
      controller: controller,
      trainIdentification: trainIdentification,
      locationReferences: locationReferences,
    );

    return controller.stream;
  }

  Future<void> _fetchWithRetry({
    required StreamController<List<RuIndication>> controller,
    required TrainIdentification trainIdentification,
    required Map<String, int> locationReferences,
  }) async {
    final company = trainIdentification.ru.companyCode;
    final trainNumber = trainIdentification.sanitizedTrainNumber;
    final startDate = trainIdentification.operatingDay ?? trainIdentification.date;

    if (trainNumber == null) {
      controller.addError(Exception('Invalid train number: ${trainIdentification.trainNumber}'));
      return;
    }

    while (!controller.isClosed) {
      try {
        await _tryFetchRuIndications(company, trainNumber, startDate, locationReferences, controller);
        return;
      } catch (e) {
        if (controller.isClosed) {
          _log.info('Request cancelled for $trainNumber, aborting retry');
          return;
        }

        _log.warning(
          'Failed to load RU indications for $trainNumber ($company) on $startDate. Retrying in ${_retryDelaySeconds}s...',
          e,
        );

        await Future.delayed(Duration(seconds: _retryDelaySeconds));
      }
    }
  }

  Future<void> _tryFetchRuIndications(
    String company,
    int trainNumber,
    DateTime startDate,
    Map<String, int> locationReferences,
    StreamController<List<RuIndication>> controller,
  ) async {
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
    controller.add(ruIndications.toList());
    controller.close();
  }
}
