import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableAdvancementViewModel');

typedef AdvancementModeChangedCallback = void Function(JourneyAdvancementModel);

/// Responsible for the (automatic) advancement of the JourneyTable.
///
/// Automatic scrolling will scroll the [JourneyTable] to the current position after an idle time has been reached.
///
///
/// The advancement can be in one of the following modes:
/// * paused (automatic scrolling is disabled)
/// * auto (automatic idle scrolling is enabled)
/// * manual (automatic idle scrolling is enabled)
class JourneyTableAdvancementViewModel extends JourneyAwareViewModel {
  JourneyTableAdvancementViewModel({
    required Stream<JourneyPositionModel> positionStream,
    required JourneyTableScrollController scrollController,
    required List<AdvancementModeChangedCallback> onAdvancementModeChanged,
    super.journeyTableViewModel,
  }) {
    _scrollController = scrollController;
    _onAdvancementModeChanged = onAdvancementModeChanged;
    _initSubscription(journeyTableViewModel.journey, positionStream);
  }

  StreamSubscription<(Journey?, JourneyPositionModel)>? _streamSubscription;

  final _idleTimeAutoScroll = Duration(seconds: DI.get<TimeConstants>().automaticAdvancementIdleTimeAutoScroll);

  late JourneyTableScrollController _scrollController;

  late List<AdvancementModeChangedCallback> _onAdvancementModeChanged;
  final _rxModel = BehaviorSubject<JourneyAdvancementModel>.seeded(Automatic());
  JourneyPoint? _currentPosition;
  JourneyPoint? _lastPosition;
  SignaledPosition? _lastSignaledPosition;

  final BehaviorSubject<bool> _rxAutomaticIdleScrollingActive = BehaviorSubject.seeded(false);
  Timer? _idleScrollTimer;
  bool _isInAutomaticScrollingZone = false;

  bool _isDisposed = false;

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
    _setModel(nextModel);
    _emitAutomaticIdleScrolling();

    if (_rxModel.value is! Paused) _scrollToCurrentPositionIfInAutoScrollingZone();
  }

  void scrollToCurrentPositionIfNotPaused() {
    if (_rxModel.value is! Paused) _scrollToCurrentPositionIfInAutoScrollingZone();
  }

  void setAdvancementModeToManual() {
    final nextModel = switch (modelValue) {
      Paused() => Paused(next: Manual()),
      Manual() || Automatic() => Manual(),
    };
    _setModel(nextModel);
    if (_rxAutomaticIdleScrollingActive.value) _scrollToCurrentPosition();
  }

  void resetIdleScrollTimer() {
    if (_isDisposed) return;

    if (_rxAutomaticIdleScrollingActive.value) {
      _idleScrollTimer?.cancel();
      _idleScrollTimer = Timer(_idleTimeAutoScroll, () {
        if (_rxAutomaticIdleScrollingActive.value) {
          _log.fine(
            'Screen idle time of ${_idleTimeAutoScroll.inSeconds} seconds reached. Scrolling to current position',
          );
          _scrollToCurrentPosition();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
    _idleScrollTimer?.cancel();
    _idleScrollTimer = null;
    _rxModel.close();
    _isDisposed = true;
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

          _setIsInAutomaticScrollingZone(journey);

          _emitAutomaticIdleScrolling();

          _onLastSignaledPositionChanged(journey.metadata.signaledPosition);

          if (_idleScrollingActiveAndTimerInactive && _lastPositionHasChanged) {
            _scrollToCurrentPosition();
          }
        });
  }

  void _onLastSignaledPositionChanged(SignaledPosition? signaledPosition) {
    final signaledPositionChanged = signaledPosition != _lastSignaledPosition;
    _lastSignaledPosition = signaledPosition;
    if (signaledPositionChanged) _setAdvancementModelToNonManual();
  }

  void _setIsInAutomaticScrollingZone(Journey journey) {
    final firstServicePoint = journey.data.whereType<ServicePoint>().firstOrNull;
    final firstServicePointOrder = firstServicePoint?.order ?? 0;
    final currentPositionOrder = _currentPosition?.order ?? 0;

    _isInAutomaticScrollingZone =
        _currentPosition != journey.metadata.journeyStart && currentPositionOrder >= firstServicePointOrder;
  }

  void _scrollToCurrentPositionIfInAutoScrollingZone() {
    if (_isInAutomaticScrollingZone) _scrollToCurrentPosition();
  }

  void _resetModel() {
    _isInAutomaticScrollingZone = false;
    _emitAutomaticIdleScrolling();
    _setModel(Automatic());
  }

  void _setModel(JourneyAdvancementModel model) {
    _rxModel.add(model);
    for (final callback in _onAdvancementModeChanged) {
      callback.call(model);
    }
  }

  void _emitAutomaticIdleScrolling() {
    if (_isInAutomaticScrollingZone && modelValue is! Paused) {
      _rxAutomaticIdleScrollingActive.add(true);
    } else {
      _rxAutomaticIdleScrollingActive.add(false);
    }
  }

  void _setAdvancementModelToNonManual() {
    final nextModel = switch (modelValue) {
      Paused() => Paused(next: Automatic()),
      Manual() || Automatic() => Automatic(),
    };
    _setModel(nextModel);
  }

  bool get _idleScrollingActiveAndTimerInactive {
    return _rxAutomaticIdleScrollingActive.value && !(_idleScrollTimer?.isActive ?? false);
  }

  bool get _lastPositionHasChanged => _currentPosition != _lastPosition;

  void _scrollToCurrentPosition() {
    if (_isDisposed) return;

    _idleScrollTimer?.cancel();

    _lastPosition = _currentPosition;
    if (_currentPosition == null) return;
    _scrollController.scrollToJourneyPoint(_currentPosition);
  }

  @override
  void journeyIdentificationChanged(_) => _resetModel();
}
