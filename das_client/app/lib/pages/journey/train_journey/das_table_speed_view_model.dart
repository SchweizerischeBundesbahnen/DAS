import 'dart:async';
import 'dart:math';

import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

/// The DASTableSpeedViewModel is responsible for handling the displayed speeds for each row in the
/// [DASTable] for the `lineSpeed` and `advisedSpeed` columns **only**.
///
/// It takes into account:
///
/// * the current stickiness of the row to always display speeds in the sticky header row
/// * ETCS protection sections to hide line speeds and no adaption of the advised speed column for these sections
/// * vPRO speeds and ADL speeds for the `advisedSpeed` column
class DASTableSpeedViewModel {
  DASTableSpeedViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<TrainJourneySettings> settingsStream,
  }) {
    _init(journeyStream, settingsStream);
  }

  late StreamSubscription<Journey?> _journeySubscription;
  late StreamSubscription<TrainJourneySettings> _settingsSubscription;

  TrainJourneySettings? _settings;
  Journey? _journey;

  TrainSeries? _currentTrainSeries;
  int? _currentBreakSeries;

  final List<BehaviorSubject<SingleSpeed?>> _rxLineSpeeds = [];

  Stream<SingleSpeed?>? lineSpeedFor(int rowIndex) {
    final streamController = _rxLineSpeeds.elementAtOrNull(rowIndex);
    return streamController?.stream.distinct();
  }

  void dispose() {
    for (final streamController in _rxLineSpeeds) {
      streamController.close();
    }
    _settingsSubscription.cancel();
    _journeySubscription.cancel();
  }

  SingleSpeed? previousLineSpeed(int rowIndex) {
    if (_journey == null || _settings == null) return null;

    final currentBreakSeries = _settings!.resolvedBreakSeries(_journey!.metadata);
    final end = min(_journey!.data.length, rowIndex);
    final previousSpeeds = _journey!.data
        .getRange(0, end)
        .map((d) => d.speeds.speedFor(currentBreakSeries?.trainSeries, breakSeries: currentBreakSeries?.breakSeries))
        .nonNulls
        .map((trainSeriesSpeed) => trainSeriesSpeed.speed)
        .whereType<SingleSpeed>();

    return previousSpeeds.lastOrNull;
  }

  SingleSpeed? previousCalculatedSpeed(int rowIndex) {
    if (_journey == null) return null;

    final end = min(_journey!.data.length, rowIndex);
    final previousData = _journey!.data.getRange(0, end);

    final servicePoints = previousData.whereType<ServicePoint>().toList();

    final previousCalculatedSpeed = servicePoints.map((sP) => sP.calculatedSpeed).nonNulls;
    return previousCalculatedSpeed.lastOrNull;
  }

  void _init(Stream<Journey?> journeyStream, Stream<TrainJourneySettings> settingsStream) {
    _journeySubscription = journeyStream.listen((journey) => _handleJourneyUpdate(journey));
    _settingsSubscription = settingsStream.listen((settings) {
      _settings = settings;
      _currentTrainSeries = settings.selectedBreakSeries?.trainSeries;
      _currentBreakSeries = settings.selectedBreakSeries?.breakSeries;
    });
  }

  void _handleJourneyUpdate(Journey? journey) {
    _journey = journey; // TODO: remove this line maybe in the end
    _updateLineSpeeds(journey);
  }

  void _updateLineSpeeds(Journey? journey) {
    if (journey == null) return _addNullAndCancelAllLineSpeeds();
    _removeInexistentLineSpeeds(journey);
    _addLineSpeeds(journey);
  }

  void _addLineSpeeds(Journey journey) {
    for (final (idx, data) in journey.data.indexed) {
      final speed = data.speeds.speedFor(_currentTrainSeries, breakSeries: _currentBreakSeries);
      final streamController = _rxLineSpeeds.elementAtOrNull(idx);
      if (streamController == null) {
        _rxLineSpeeds.insert(idx, BehaviorSubject<SingleSpeed?>.seeded(speed?.speed as SingleSpeed?));
        continue;
      }

      streamController.add(speed?.speed as SingleSpeed?);
    }
  }

  void _addNullAndCancelAllLineSpeeds() {
    for (final value in _rxLineSpeeds) {
      value.add(null);
      value.close();
    }
    _rxLineSpeeds.clear();
  }

  void _removeInexistentLineSpeeds(Journey journey) {
    if (_rxLineSpeeds.length <= journey.data.length) return;
    _rxLineSpeeds.getRange(journey.data.length, _rxLineSpeeds.length).forEach((streamController) {
      streamController.add(null);
      streamController.close();
    });
    _rxLineSpeeds.removeRange(journey.data.length, _rxLineSpeeds.length);
  }
}
