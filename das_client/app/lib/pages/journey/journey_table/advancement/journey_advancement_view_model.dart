import 'dart:async';

import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_table_scroll_controller.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyAdvancementViewModel');

/// Responsible for the advancement of the JourneyTable.
///
/// The advancement can be in one of the following modes:
/// * paused (auto scrolling is disabled)
/// * auto (auto scrolling is enabled)
/// * manual (auto scrolling is enabled)
///
/// Automatic scrolling will scroll the [JourneyTable] to the current position after an idle time has been reached.
class JourneyAdvancementViewModel {
  JourneyAdvancementViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel> positionStream,
    required JourneyTableScrollController scrollController,
  }) {
    _scrollController = scrollController;
    _initSubscription(journeyStream, positionStream);
  }

  StreamSubscription<(Journey?, JourneyPositionModel)>? _streamSubscription;

  final BehaviorSubject<bool> _rxIsAdvancingActive = BehaviorSubject.seeded(false);

  late JourneyTableScrollController _scrollController;

  Stream<bool> get isAdvancingActive => _rxIsAdvancingActive.stream;

  JourneyPoint? _currentPosition;

  void pauseAutomaticAdvancement() {}

  void startAutomaticAdvancement() {}

  void advanceToCurrentPosition() {
    _scrollController.scrollToPosition(_currentPosition);
  }

  void _initSubscription(Stream<Journey?> journeyStream, Stream<JourneyPositionModel> positionStream) {
    _streamSubscription =
        CombineLatestStream.combine2(
          journeyStream,
          positionStream,
          (a, b) => (a, b),
        ).listen((data) async {
          final journey = data.$1;
          final position = data.$2;

          if (journey == null) {
            return;
          }

          _currentPosition = position.currentPosition;

          final firstServicePoint = journey.data.whereType<ServicePoint>().firstOrNull;

          final firstServicePointOrder = firstServicePoint?.order ?? 0;
          final currentPositionOrder = _currentPosition?.order ?? 0;

          final isAdvancingActive =
              true &&
              (_currentPosition != journey.metadata.journeyStart) &&
              currentPositionOrder >= firstServicePointOrder;

          _log.fine(isAdvancingActive);

          if (isAdvancingActive) {
            _scrollController.scrollToPosition(_currentPosition);
          }
          // _rxIsAutomaticAdvancementActive.add(isAdvancingActive);
          // if (!isAdvancingActive) {
          //   return;
          // }

          // final targetPosition = _calculateTargetPosition();
          // if (_lastScrollPosition != targetPosition && targetPosition != null && _lastTouch == null) {
          //   _scrollToPosition(targetPosition);
          // }
        });
  }

  void dispose() {
    _streamSubscription?.cancel();
  }
}
