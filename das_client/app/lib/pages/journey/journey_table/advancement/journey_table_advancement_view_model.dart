import 'dart:async';
import 'dart:ui';

import 'package:app/pages/journey/journey_table/advancement/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_table_scroll_controller.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyAdvancementViewModel');

/// Responsible for the (automatic) advancement of the JourneyTable.
///
/// Automatic scrolling will scroll the [JourneyTable] to the current position after an idle time has been reached.
///
///
/// The advancement can be in one of the following modes:
/// * paused (automatic scrolling is disabled)
/// * auto (automatic scrolling is enabled)
/// * manual (automatic scrolling is enabled)
///
class JourneyTableAdvancementViewModel {
  JourneyTableAdvancementViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel> positionStream,
    required JourneyTableScrollController scrollController,
    required VoidCallback onAdvancementModeToggled,
  }) {
    _scrollController = scrollController;
    _onAdvancementModeToggled = onAdvancementModeToggled;
    _initSubscription(journeyStream, positionStream);
  }

  StreamSubscription<(Journey?, JourneyPositionModel)>? _streamSubscription;

  late JourneyTableScrollController _scrollController;
  late VoidCallback _onAdvancementModeToggled;
  final BehaviorSubject<bool> _rxAutomaticScrollingActive = BehaviorSubject.seeded(false);
  final _rxModel = BehaviorSubject<JourneyAdvancementModel>.seeded(Automatic());
  JourneyPoint? _currentPosition;
  SignaledPosition? _lastSignaledPosition;

  bool _isInAutomaticScrollingZone = false;

  Stream<bool> get automaticScrollingActive => _rxAutomaticScrollingActive.distinct();

  bool get automaticScrollingActiveValue => _rxAutomaticScrollingActive.value;

  Stream<JourneyAdvancementModel> get model => _rxModel.distinct();

  JourneyAdvancementModel get modelValue => _rxModel.value;

  /// Toggles between [Paused], [Manual] and [Automatic].
  ///
  /// [Manual] => [Paused]
  /// [Automatic] => [Paused]
  ///
  /// If in manual mode and no new signaledPosition in the meantime
  /// toggles from [Paused] to [Manual]. Else toggles from [Paused] to [Automatic].
  void toggleAdvancementMode() {
    final nextModel = switch (modelValue) {
      Paused(next: final next) => next,
      Automatic() => Paused(next: Automatic()),
      Manual() => Paused(next: Manual()),
    };
    _rxModel.add(nextModel);
    _emitAutomaticScrolling();
    _onAdvancementModeToggled.call();
  }

  // void setAdvancementModeToManual() {
  //   _rxModel.add(Manual());
  //   _emitAutomaticScrolling();
  // }

  // void advanceToCurrentPosition() {
  //   _scrollController.scrollToJourneyPoint(_currentPosition);
  // }

  void dispose() {
    _streamSubscription?.cancel();
    _rxModel.close();
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
            _isInAutomaticScrollingZone = false;
            _emitAutomaticScrolling();
            _resetModel();
            return;
          }
          _lastSignaledPosition = journey.metadata.signaledPosition;
          _currentPosition = position.currentPosition;

          final firstServicePoint = journey.data.whereType<ServicePoint>().firstOrNull;

          final firstServicePointOrder = firstServicePoint?.order ?? 0;
          final currentPositionOrder = _currentPosition?.order ?? 0;

          // final isAdvancingActive =
          //     true &&
          //     (_currentPosition != journey.metadata.journeyStart) &&
          //     currentPositionOrder >= firstServicePointOrder;

          _isInAutomaticScrollingZone =
              _currentPosition != journey.metadata.journeyStart && currentPositionOrder >= firstServicePointOrder;

          _emitAutomaticScrolling();

          if (automaticScrollingActiveValue) {
            _scrollController.scrollToJourneyPoint(_currentPosition);
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

  void _resetModel() {
    _rxModel.add(Paused(next: Automatic()));
  }

  void _emitAutomaticScrolling() {
    if (_isInAutomaticScrollingZone && modelValue is! Paused) {
      _rxAutomaticScrollingActive.add(true);
    } else {
      _rxAutomaticScrollingActive.add(false);
    }
  }
}
