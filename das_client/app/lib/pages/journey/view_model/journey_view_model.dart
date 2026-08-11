import 'dart:async';

import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:collection/collection.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

class JourneyViewModel {
  JourneyViewModel({
    required this._settingsRepository,
    required this._sferaJourneyViewModel,
    required this._ruIndicationsRepository,
  }) {
    _init();
  }

  Stream<Journey?> get journey => _rxJourney.stream;

  Stream<String?> get formattedTrainIdentifier => _rxFormattedTrainIdentifier.stream;

  Journey? get journeyValue => _rxJourney.value;

  final SettingsRepository _settingsRepository;
  final SferaJourneyViewModel _sferaJourneyViewModel;
  final RuIndicationsRepository _ruIndicationsRepository;

  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);
  final _rxFormattedTrainIdentifier = BehaviorSubject<String?>.seeded(null);
  final _ruIndications = <RuIndication>[];

  StreamSubscription? _journeySubscription;
  StreamSubscription<List<RuIndication>>? _ruIndicationsSubscription;

  bool _hasShuntingMovement() => journeyValue?.data.any((data) => data is ShuntingMovement) ?? false;

  void dispose() {
    _rxJourney.close();
    _journeySubscription?.cancel();
    _ruIndicationsSubscription?.cancel();
  }

  void _init() {
    _initJourneySubscription();
    _initJourneySubscription();
  }

  void _initJourneySubscription() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaJourneyViewModel.journey.listen((sferaJourney) async {
      final lastJourney = journeyValue;
      _handleRuIndications(sferaJourney, lastJourney);
      _handleFormattedTrainIdentification(sferaJourney);
      _emit(sferaJourney);
    });
  }

  void _handleRuIndications(Journey? journey, Journey? lastJourney) {
    if (journey?.metadata.trainIdentification != lastJourney?.metadata.trainIdentification) {
      _ruIndications.clear();
    }

    if (_shouldLoadRuIndications(journey, lastJourney)) {
      _loadRuIndications(journey);
    }
  }

  void _handleFormattedTrainIdentification(Journey? journey) async {
    final trainIdentification = journey?.metadata.trainIdentification;
    if (trainIdentification == null) {
      _rxFormattedTrainIdentifier.add(null);
    } else {
      final trainNumber = trainIdentification.trainNumber;
      final companyName = await _settingsRepository.getCompanyForCode(trainIdentification.companyCode);
      final displayedTrainNumber = _hasShuntingMovement() ? '${trainNumber}R / $trainNumber' : trainNumber;
      _rxFormattedTrainIdentifier.add('$displayedTrainNumber ${companyName ?? ''}'.trim());
    }
  }

  bool _shouldLoadRuIndications(Journey? journey, Journey? lastJourney) {
    if (lastJourney == null || journey == null) {
      return true;
    }
    final locationReferences = [for (final it in journey.data.whereType<ServicePoint>()) it.locationCode];
    final lastLocationReferences = [for (final it in lastJourney.data.whereType<ServicePoint>()) it.locationCode];

    return const ListEquality().equals(locationReferences, lastLocationReferences) == false;
  }

  void _loadRuIndications(Journey? journey) {
    final trainIdentification = journey?.metadata.trainIdentification;
    if (trainIdentification != null) {
      final servicePoints = journey!.data.whereType<ServicePoint>();
      final locationReferences = {for (final it in servicePoints) it.locationCode: it.order};

      _ruIndicationsSubscription?.cancel();
      _ruIndicationsSubscription = _ruIndicationsRepository
          .fetchRuIndications(
            trainIdentification: trainIdentification,
            locationReferences: locationReferences,
          )
          .listen((ruIndications) {
            _ruIndications.clear();
            _ruIndications.addAll(ruIndications);
            _emit();
          });
    }
  }

  void _emit([Journey? sferaJourney]) {
    final journey = sferaJourney ?? _sferaJourneyViewModel.journeyValue;
    if (journey == null) {
      _emitValue(null);
    } else {
      final mergedData = [...journey.data, ..._ruIndications].sorted((a1, a2) => a1.compareTo(a2));
      final mergedJourney = Journey(metadata: journey.metadata, data: mergedData, valid: journey.valid);
      _emitValue(mergedJourney);
    }
  }

  void _emitValue(Journey? journey) {
    if (!_rxJourney.isClosed) {
      _rxJourney.add(journey);
    }
  }
}
