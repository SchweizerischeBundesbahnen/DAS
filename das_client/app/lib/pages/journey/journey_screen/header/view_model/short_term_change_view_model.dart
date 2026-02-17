import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/extension/short_term_change_extension.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/model/short_term_change_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _logger = Logger('ShortTermChangeViewModel');

class ShortTermChangeViewModel extends JourneyAwareViewModel {
  ShortTermChangeViewModel({
    required super.journeyTableViewModel,
    required JourneyPositionViewModel journeyPositionViewModel,
  }) : _journeyPositionViewModel = journeyPositionViewModel {
    _initJourneyPositionSubscription();
  }

  final JourneyPositionViewModel _journeyPositionViewModel;

  StreamSubscription<JourneyPositionModel>? _journeyPositionSubscription;

  final BehaviorSubject<ShortTermChangeModel> _rxSubject = BehaviorSubject.seeded(NoShortTermChanges());

  JourneyPoint? _lastCurrentPosition;
  bool _displayNewShortTermChanges = false;

  Timer? _timer;

  Stream<ShortTermChangeModel> get model => _rxSubject.stream.distinct();

  ShortTermChangeModel get modelValue => _rxSubject.value;

  @override
  void journeyUpdated(Journey? journey) {
    if (!_hasNewShortTermChanges(journey)) return;
    _displayNewShortTermChanges = true;
    _calculateAndEmitModel(journey: journey, currentPosition: _lastCurrentPosition);
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _lastCurrentPosition = null;
    _rxSubject.add(NoShortTermChanges());

    if (journey?.metadata.shortTermChanges.isEmpty ?? true) return;
    _displayNewShortTermChanges = true;
    _calculateAndEmitModel(journey: journey, currentPosition: null);
  }

  @override
  void dispose() {
    _journeyPositionSubscription?.cancel();
    _rxSubject.close();
    _timer?.cancel();
    super.dispose();
  }

  void _initJourneyPositionSubscription() {
    _journeyPositionSubscription?.cancel();
    _journeyPositionSubscription = _journeyPositionViewModel.model.listen((model) {
      final currentPosition = model.currentPosition;
      if (_lastCurrentPosition == currentPosition) return;

      _lastCurrentPosition = currentPosition;
      _calculateAndEmitModel(journey: lastJourney, currentPosition: currentPosition);
    });
  }

  void _calculateAndEmitModel({Journey? journey, JourneyPoint? currentPosition}) {
    _timer?.cancel();
    final shortTermChanges = journey?.metadata.shortTermChanges.toList(growable: false) ?? [];

    if (shortTermChanges.isEmpty) {
      _emitEmptyWithLog();
      return;
    }

    if (currentPosition == null || currentPosition == journey?.metadata.journeyStart) {
      // journey has not started yet
      _emitLastingWithLog(shortTermChanges);
      return;
    }

    final shortTermChangeInSight = _calculateClosestShortTermChangeInSight(shortTermChanges);
    if (shortTermChangeInSight != null) {
      // in case there is only one and it's already in sight, do not display afterwards anymore
      if (shortTermChanges.length == 1) _displayNewShortTermChanges = false;
      _emitChangeInSightWithLog(shortTermChangeInSight);
      return;
    }

    if (_displayNewShortTermChanges) {
      _displayNewShortTermChanges = false;
      _emitTimedWithLog(shortTermChanges);
      return;
    }

    _emitNoRelevantShortTermChangesWithLog();
  }

  void _emitEmptyWithLog() {
    _logger.fine('No Short Term Changes in Journey - emitting empty');
    _rxSubject.add(NoShortTermChanges());
  }

  void _emitLastingWithLog(Iterable<ShortTermChange> shortTermChanges) {
    _logger.fine('ShortTermChanges within journey that has not yet started. Emitting...');
    _emitSingleOrMultipleWithLog(shortTermChanges);
  }

  void _emitChangeInSightWithLog(ShortTermChange shortTermChangeInSight) {
    _logger.fine('Emitting inSight shortTermChange: $shortTermChangeInSight');
    _rxSubject.add(
      SingleShortTermChange(
        shortTermChangeType: shortTermChangeInSight.toChangeType,
        servicePointName: shortTermChangeInSight.startData.name,
      ),
    );
  }

  void _emitNoRelevantShortTermChangesWithLog() {
    _logger.fine('No short term changes for the current position relevant!');
    _rxSubject.add(NoShortTermChanges());
  }

  void _emitTimedWithLog(Iterable<ShortTermChange> shortTermChanges) {
    _logger.fine('Setting timer for timed ShortTermChange display!');
    _timer?.cancel();
    _timer = Timer(Duration(seconds: DI.get<TimeConstants>().newShortTermChangesDisplaySeconds), () {
      _logger.fine('Timer on ShortTermChange display reset reached.');
      if (!_rxSubject.isClosed) _rxSubject.add(NoShortTermChanges());
    });

    _emitSingleOrMultipleWithLog(shortTermChanges);
  }

  void _emitSingleOrMultipleWithLog(Iterable<ShortTermChange> shortTermChanges) {
    assert(shortTermChanges.isNotEmpty);
    if (shortTermChanges.length > 1) {
      _logger.fine('Multiple Short Term Changes in Journey. Emitting...');
      _rxSubject.add(MultipleShortTermChanges());
    } else {
      _logger.fine('Single Short Term Change in Journey. Emitting...');
      final change = shortTermChanges.first;
      _rxSubject.add(
        SingleShortTermChange(
          shortTermChangeType: change.toChangeType,
          servicePointName: change.startData.name,
        ),
      );
    }
  }

  ShortTermChange? _calculateClosestShortTermChangeInSight(Iterable<ShortTermChange> shortTermChanges) {
    assert(shortTermChanges.isNotEmpty);
    // short term changes in sight are between current position and maximum of two service points ahead

    final beginOfSight = _lastCurrentPosition?.order;
    if (beginOfSight == null || lastJourney == null) {
      _logger.fine('Cannot calculate short term change in sight without journey of current position!');
      return null;
    }

    final servicePointsAhead = lastJourney!.data
        .whereType<ServicePoint>()
        .where((sP) => sP.order > beginOfSight)
        .sortedBy((sP) => sP.order);
    final endOfSight = servicePointsAhead.take(2).lastOrNull?.order;

    if (endOfSight != null) {
      return _shortestChangeInSightWithHighestPriority(
        shortTermChanges,
        (change) => change.startOrder! >= beginOfSight && change.startOrder! <= endOfSight,
      );
    } else {
      return _shortestChangeInSightWithHighestPriority(
        shortTermChanges,
        (change) => change.appliesToOrder(beginOfSight),
      );
    }
  }

  ShortTermChange? _shortestChangeInSightWithHighestPriority(
    Iterable<ShortTermChange> shortTermChanges,
    bool Function(ShortTermChange change) test,
  ) {
    final shortTermChangesInSight = shortTermChanges.where(test).sortedBy((c) => c.startOrder!);
    final firstChangeOrder = shortTermChangesInSight.firstOrNull?.startOrder;
    if (firstChangeOrder == null) return null;
    return shortTermChangesInSight.where((change) => change.startOrder == firstChangeOrder).getHighestPriority;
  }

  bool _isSortedEqual(List<ShortTermChange> shortTermChanges, List<ShortTermChange> lastShortTermChanges) {
    int compareByOrderThenPriority(ShortTermChange a, ShortTermChange b) {
      final orderComparison = a.startOrder!.compareTo(b.startOrder!);
      if (orderComparison != 0) return orderComparison;
      return a.compareByPriority(b);
    }

    return ListEquality().equals(
      shortTermChanges.sorted(compareByOrderThenPriority),
      lastShortTermChanges.sorted(compareByOrderThenPriority),
    );
  }

  void _setDisplayNewShortTermChanges(Journey? journey) {
    if (_hasNewShortTermChanges(journey)) _displayNewShortTermChanges = true;
  }

  bool _hasNewShortTermChanges(Journey? journey) {
    final shortTermChanges = journey?.metadata.shortTermChanges.toList(growable: false) ?? [];
    final lastShortTermChanges = lastJourney?.metadata.shortTermChanges.toList(growable: false) ?? [];
    return !_isSortedEqual(shortTermChanges, lastShortTermChanges);
  }
}

extension on ShortTermChange {
  ShortTermChangeType get toChangeType => switch (this) {
    StopToPassChange() => .stopToPass,
    PassToStopChange() => .passToStop,
    TrainRunReroutingChange() => .trainRunRerouting,
    EndDestinationChange() => .endDestination,
  };
}
