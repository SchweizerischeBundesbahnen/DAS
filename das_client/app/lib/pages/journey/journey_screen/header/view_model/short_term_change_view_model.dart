import 'dart:async';

import 'package:app/extension/short_term_change_extension.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/model/short_term_change_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
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

  final BehaviorSubject<ShortTermChangeModel> _rxSubject = BehaviorSubject.seeded(
    ShortTermChangeModel.noShortTermChanges(),
  );

  Journey? _lastJourney;
  JourneyPoint? _lastCurrentPosition;
  bool _journeyStarted = false;
  final List<ShortTermChange> _lastShortTermChanges = [];

  Stream<ShortTermChangeModel> get model => _rxSubject.stream.distinct();

  ShortTermChangeModel get modelValue => _rxSubject.value;

  @override
  void journeyUpdated(Journey? journey) {
    _lastJourney = journey;
    _logger.fine('Updating Journey');
    _emitModel();
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    if (_lastJourney != null) {
      _logger.fine('Discarding ShortTermChanges');
      _journeyStarted = false;
      _lastCurrentPosition = null;
      _lastJourney = null;
      _lastShortTermChanges.clear();
      _rxSubject.add(ShortTermChangeModel.noShortTermChanges());
    } else {
      _lastJourney = journey;
      _emitModel();
    }
  }

  @override
  void dispose() {
    _journeyPositionSubscription?.cancel();
    super.dispose();
  }

  void _initJourneyPositionSubscription() {
    _journeyPositionSubscription?.cancel();
    _journeyPositionSubscription = _journeyPositionViewModel.model.listen((model) {
      _lastCurrentPosition = model.currentPosition;
      if (_lastCurrentPosition != null && _lastCurrentPosition != _lastJourney?.metadata.journeyStart) {
        _journeyStarted = true;
      }
      _emitModel();
    });
  }

  void _emitModel() {
    final shortTermChanges = _lastJourney?.metadata.shortTermChanges ?? [];

    if (shortTermChanges.isEmpty) {
      _emitEmptyWithLog();
      return;
    }

    if (!_journeyStarted) {
      _emitLastingWithLog(shortTermChanges);
      return;
    }

    final shortTermChangeInSight = _calculateClosestShortTermChangeInSight(shortTermChanges);
    if (shortTermChangeInSight != null) {
      _emitChangeInSightWithLog(shortTermChangeInSight);
      return;
    }

    // if (!_isEqual(shortTermChanges, _lastShortTermChanges)) {
    //   _emitTimedWithLog(shortTermChanges);
    //   return;
    // }
    //
    _emitNoRelevantShortTermChangesWithLog();
  }

  void _emitEmptyWithLog() {
    _logger.fine('No Short Term Changes in Journey - emitting empty');
    _rxSubject.add(ShortTermChangeModel.noShortTermChanges());
  }

  void _emitLastingWithLog(Iterable<ShortTermChange> shortTermChanges) {
    assert(shortTermChanges.isNotEmpty);

    if (shortTermChanges.length > 1) {
      _logger.fine('Multiple Short Term Changes in Journey that has not yet started. Emitting...');
      _rxSubject.add(ShortTermChangeModel.multipleShortTermChanges());
    } else {
      _logger.fine('Single Short Term Change in Journey that has not yet started. Emitting...');
      final change = shortTermChanges.first;
      _rxSubject.add(
        ShortTermChangeModel.singleShortTermChange(
          shortTermChangeType: change.toChangeType,
          servicePointName: change.startData.name,
        ),
      );
    }
  }

  void _emitChangeInSightWithLog(ShortTermChange shortTermChangeInSight) {
    _logger.fine('Emitting inSight shortTermChange: $shortTermChangeInSight');
    _rxSubject.add(
      ShortTermChangeModel.singleShortTermChange(
        shortTermChangeType: shortTermChangeInSight.toChangeType,
        servicePointName: shortTermChangeInSight.startData.name,
      ),
    );
  }

  void _emitNoRelevantShortTermChangesWithLog() {
    _logger.fine('No short term changes for the current position relevant!');
    _rxSubject.add(ShortTermChangeModel.noShortTermChanges());
  }

  ShortTermChange? _calculateClosestShortTermChangeInSight(Iterable<ShortTermChange> shortTermChanges) {
    assert(shortTermChanges.isNotEmpty);
    // short term changes in sight are between current position and maximum of two service points ahead

    final beginOfSight = _lastCurrentPosition?.order;
    if (beginOfSight == null || _lastJourney == null) {
      _logger.fine('Cannot calculate short term change in sight without journey of current position!');
      return null;
    }

    final servicePointsAhead = _lastJourney!.data
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
}

extension on ShortTermChange {
  ShortTermChangeType get toChangeType => switch (this) {
    Stop2PassChange() => .stop2Pass,
    Pass2StopChange() => .pass2Stop,
    TrainRunReroutingChange() => .trainRunRerouting,
    EndDestinationChange() => .endDestination,
  };
}
