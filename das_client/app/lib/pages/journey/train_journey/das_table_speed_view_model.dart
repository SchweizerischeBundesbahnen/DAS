import 'dart:async';
import 'dart:collection';
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
  List<BaseData>? _rows;

  int? _stickyIndex;

  final _rxLineSpeeds = SplayTreeMap<int, BehaviorSubject<SingleSpeed?>>();

  /// TODO: implement a separate ViewModel for this here and in the TrainJourney
  void _updateRows() {
    final currentBreakSeries = _settings?.resolvedBreakSeries(_journey?.metadata);
    _rows = _journey?.data
        .whereNot((it) => _isCurvePointWithoutSpeed(it, _journey, _settings))
        .groupBaliseAndLeveLCrossings(_settings?.expandedGroups ?? [])
        .hideRepeatedLineFootNotes(_journey?.metadata.currentPosition)
        .hideFootNotesForNotSelectedTrainSeries(currentBreakSeries?.trainSeries)
        .combineFootNoteAndOperationalIndication()
        .sortedBy((data) => data.order);
  }

  bool _isCurvePointWithoutSpeed(BaseData data, Journey? journey, TrainJourneySettings? settings) {
    final breakSeries = settings?.resolvedBreakSeries(journey?.metadata);

    return data.type == Datatype.curvePoint &&
        data.localSpeeds?.speedFor(breakSeries?.trainSeries, breakSeries: breakSeries?.breakSeries) == null;
  }

  Stream<SingleSpeed?>? lineSpeedFor(int identifier) => _rxLineSpeeds[identifier]?.stream;

  SingleSpeed? lineSpeedValueFor(int identifier) => _rxLineSpeeds[identifier]?.stream.valueOrNull;

  void updateStickyIndex(int index) {
    if (_stickyIndex == index) return;
    final oldStickyIndex = _stickyIndex;

    _stickyIndex = index;
    if (oldStickyIndex != null) _singleLineSpeedUpdate(oldStickyIndex);
    _singleLineSpeedUpdate(_stickyIndex!);
  }

  void dispose() {
    _clearAllLineSpeeds();
    _settingsSubscription.cancel();
    _journeySubscription.cancel();
  }

  SingleSpeed? previousLineSpeed(int identifier) {
    final int? previousIdxWithSpeed = _rxLineSpeeds.lastKeyBefore(identifier);
    return _rxLineSpeeds[previousIdxWithSpeed]?.valueOrNull;
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
    _journeySubscription = journeyStream.listen((journey) {
      _journey = journey;
      _updateRows();
      _removeAndUpdateLineSpeeds();
    });
    _settingsSubscription = settingsStream.listen((settings) {
      _settings = settings;
      _updateRows();
      _removeAndUpdateLineSpeeds();
    });
  }

  void _removeAndUpdateLineSpeeds() {
    if (_journey == null) return _clearAllLineSpeeds();
    _removeInexistentLineSpeeds();
    _updateAllLineSpeeds();
  }

  void _updateAllLineSpeeds() {
    if (_rows == null) return;
    for (var i = 0; i < _rows!.length; i++) {
      _singleLineSpeedUpdate(i);
    }
  }

  void _singleLineSpeedUpdate(int rowIndex) {
    if (_rows == null) return;
    final data = _rows?.elementAtOrNull(rowIndex);
    // if (data == null) return _safeRemoveFromLineSpeeds(rowIndex);

    final resolvedBreakSeries = _settings?.resolvedBreakSeries(_journey?.metadata);
    final TrainSeriesSpeed? speed = data?.speeds.speedFor(
      resolvedBreakSeries?.trainSeries,
      breakSeries: resolvedBreakSeries?.breakSeries,
    );
    SingleSpeed? lineSpeed = speed?.speed as SingleSpeed?;
    if (data?.type == Datatype.servicePoint && _stickyIndex == rowIndex) lineSpeed ??= previousLineSpeed(rowIndex);

    if (_rxLineSpeeds.containsKey(rowIndex)) {
      _rxLineSpeeds[rowIndex]!.add(lineSpeed);
    } else if (lineSpeed != null) {
      _rxLineSpeeds[rowIndex] = BehaviorSubject<SingleSpeed?>.seeded(lineSpeed);
    }
  }

  void _clearAllLineSpeeds() {
    for (final value in _rxLineSpeeds.values) {
      value.add(null);
      value.close();
    }
    _rxLineSpeeds.clear();
  }

  void _removeInexistentLineSpeeds() {
    final keys = List.from(_rxLineSpeeds.keys, growable: false);
    for (final key in keys) {
      if (key >= _rows?.length) _safeRemoveFromLineSpeeds(key);
    }
  }

  void _safeRemoveFromLineSpeeds(int idx) {
    final toBeRemoved = _rxLineSpeeds[idx];
    toBeRemoved?.add(null);
    toBeRemoved?.close();
    (toBeRemoved != null) ? _rxLineSpeeds.remove(idx) : null;
  }
}
