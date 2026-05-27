import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
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
class JourneyTableAdvancementViewModel {
  JourneyTableAdvancementViewModel({
    required this._scrollController,
    required this._journeySettingsViewModel,
    required this._detailModalViewModel,
    required this._chevronPositionStream,
    required this._journeyViewModel,
  }) {
    _initSubscription();
  }

  final List<StreamSubscription> _streamSubscription = [];

  final _idleTimeAutoScroll = Duration(seconds: DI.get<TimeConstants>().automaticAdvancementIdleTimeAutoScroll);

  final JourneyTableScrollController _scrollController;
  final JourneySettingsViewModel _journeySettingsViewModel;
  final DetailModalViewModel _detailModalViewModel;
  final Stream<ChevronPositionModel> _chevronPositionStream;
  final JourneyViewModel _journeyViewModel;

  JourneyPoint? _currentPosition;
  JourneyPoint? _lastPosition;
  SignaledPosition? _lastSignaledPosition;
  BrakeSeries? _latestBrakeSeries;

  final BehaviorSubject<bool> _rxAutomaticIdleScrollingActive = BehaviorSubject.seeded(false);
  Timer? _idleScrollTimer;
  bool _isInAutomaticScrollingZone = false;

  bool _isDisposed = false;

  JourneyAdvancementModel get _modelValue => _journeySettingsViewModel.modelValue.journeyAdvancementModel;

  /// Toggles between [Paused], [Manual] and [Automatic].
  ///
  /// [Manual] => [Paused]
  /// [Automatic] => [Paused]
  ///
  /// If in manual mode and no new signaledPosition in the meantime
  /// toggles from [Paused] to [Manual]. Else toggles from [Paused] to [Automatic].
  void toggleAdvancementMode() {
    final nextModel = switch (_modelValue) {
      Paused(next: final next) => next,
      Automatic() => Paused(next: const Automatic()),
      Manual() => Paused(next: const Manual()),
    };
    _setModel(nextModel);
    _emitAutomaticIdleScrolling();

    if (nextModel is! Paused) _scrollToCurrentPositionIfInAutoScrollingZone();
  }

  void _scrollToCurrentPositionIfNotPaused() {
    if (_modelValue is! Paused) _scrollToCurrentPositionIfInAutoScrollingZone();
  }

  void setAdvancementModeToManual() {
    final nextModel = switch (_modelValue) {
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

  void dispose() {
    _isDisposed = true;
    for (final subscription in _streamSubscription) {
      subscription.cancel();
    }
    _idleScrollTimer?.cancel();
    _idleScrollTimer = null;
  }

  void _initSubscription() {
    _streamSubscription.add(
      CombineLatestStream.combine2(
        _journeyViewModel.journey,
        _chevronPositionStream.distinct(),
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
      }),
    );
    _streamSubscription.add(
      _journeySettingsViewModel.model.listen((data) {
        if (data.currentBrakeSeries != _latestBrakeSeries) {
          _scrollToCurrentPositionIfNotPaused();
        }
        _latestBrakeSeries = data.currentBrakeSeries;
      }),
    );
    _streamSubscription.add(
      _detailModalViewModel.openModalType.listen((data) {
        if (data == null) {
          _scrollToCurrentPositionIfNotPaused();
        }
      }),
    );
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

    final journeyStart = journey.data.whereType<JourneyPoint>().firstOrNull;
    _isInAutomaticScrollingZone = _currentPosition != journeyStart && currentPositionOrder >= firstServicePointOrder;
  }

  void _scrollToCurrentPositionIfInAutoScrollingZone() {
    if (_isInAutomaticScrollingZone) _scrollToCurrentPosition();
  }

  void _setModel(JourneyAdvancementModel model) {
    if (_modelValue != model) {
      _journeySettingsViewModel.updateJourneyAdvancement(model);
    }
  }

  void _emitAutomaticIdleScrolling() {
    if (_isInAutomaticScrollingZone && _modelValue is! Paused) {
      _rxAutomaticIdleScrollingActive.add(true);
    } else {
      _rxAutomaticIdleScrollingActive.add(false);
    }
  }

  void _setAdvancementModelToNonManual() {
    final nextModel = switch (_modelValue) {
      Paused() => Paused(next: const Automatic()),
      Manual() || Automatic() => const Automatic(),
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
}
