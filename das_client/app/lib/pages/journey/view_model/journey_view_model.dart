import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneyViewModel {
  final _retryDelay = DI.get<TimeConstants>().httpRequestRetryDelaySeconds;

  JourneyViewModel({
    required this._sferaJourneyViewModel,
    required this._ruIndicationsRepository,
  }) {
    _init();
  }

  Stream<Journey?> get journey => _rxJourney.stream;

  Journey? get journeyValue => _rxJourney.value;

  final SferaJourneyViewModel _sferaJourneyViewModel;
  final RuIndicationsRepository _ruIndicationsRepository;

  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);
  final _ruIndications = <RuIndication>[];
  Timer? _retryTimer;

  StreamSubscription? _journeySubscription;

  void dispose() {
    _rxJourney.close();
    _journeySubscription?.cancel();
    _retryTimer?.cancel();
  }

  void _init() {
    _initJourneySubscription();
  }

  void _initJourneySubscription() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaJourneyViewModel.journey.listen((sferaJourney) async {
      final lastJourney = journeyValue;
      _handleRuIndications(sferaJourney, lastJourney);
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

  bool _shouldLoadRuIndications(Journey? journey, Journey? lastJourney) {
    if (lastJourney == null || journey == null) {
      return true;
    }
    final locationReferences = [for (final it in journey.data.whereType<ServicePoint>()) it.locationCode];
    final lastLocationReferences = [for (final it in journey.data.whereType<ServicePoint>()) it.locationCode];

    return const ListEquality().equals(locationReferences, lastLocationReferences) == false;
  }

  Future<void> _loadRuIndications(Journey? journey) async {
    _retryTimer?.cancel();
    final trainIdentification = journey?.metadata.trainIdentification;
    if (trainIdentification != null) {
      final servicePoints = journey!.data.whereType<ServicePoint>();
      final locationReferences = {for (final it in servicePoints) it.locationCode: it.order};
      _ruIndicationsRepository
          .fetchRuIndications(
            trainIdentification: trainIdentification,
            locationReferences: locationReferences,
          )
          .then((value) {
            _ruIndications.clear();
            _ruIndications.addAll(value);
            _emit();
          })
          .onError((error, stackTrace) {
            _retryTimer?.cancel();
            _retryTimer = Timer(Duration(seconds: _retryDelay), () {
              _loadRuIndications(_sferaJourneyViewModel.journeyValue);
            });
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
