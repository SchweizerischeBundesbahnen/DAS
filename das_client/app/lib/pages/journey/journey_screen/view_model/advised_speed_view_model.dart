import 'dart:async';
import 'dart:ui';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/advised_speed_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('AdvisedSpeedViewModel');

class AdvisedSpeedViewModel extends JourneyAwareViewModel {
  AdvisedSpeedViewModel({
    required Stream<JourneyPositionModel> journeyPositionStream,
    required NotificationPriorityQueueViewModel notificationVM,
    required LineSpeedViewModel lineSpeedViewModel,
    super.journeyViewModel,
  }) : _notificationVM = notificationVM,
       _lineSpeedViewModel = lineSpeedViewModel {
    _initJourneyStreamSubscription(journeyViewModel.journey, journeyPositionStream);
  }

  static Sound get _startSound => DI.get<DASSounds>().advisedSpeedStart;

  static Sound get _endSound => DI.get<DASSounds>().advisedSpeedEnd;

  final _endOrCancelDisplaySeconds = DI.get<TimeConstants>().advisedSpeedEndDisplaySeconds;

  Timer? _setToInactiveTimer;

  List<AdvisedSpeedSegment> _activeSegments = [];

  int _currentPositionOrder = 0;

  SingleSpeed? _activeLineSpeed;

  final NotificationPriorityQueueViewModel _notificationVM;
  final LineSpeedViewModel _lineSpeedViewModel;

  StreamSubscription<(Journey?, JourneyPositionModel)>? _journeySubscription;

  final _rxModel = BehaviorSubject<AdvisedSpeedModel>.seeded(AdvisedSpeedModel.inactive());

  Stream<AdvisedSpeedModel> get model => _rxModel.distinct();

  AdvisedSpeedModel get modelValue => _rxModel.value;

  void _initJourneyStreamSubscription(
    Stream<Journey?> journeyStream,
    Stream<JourneyPositionModel> journeyPositionStream,
  ) {
    _journeySubscription = CombineLatestStream.combine2(journeyStream, journeyPositionStream, (a, b) => (a, b)).listen((
      data,
    ) {
      final journey = data.$1;
      final journeyPosition = data.$2;
      if (_cannotDetermineAdvisedSpeed(journey, journeyPosition)) return;

      _handleUpdate(journey, journeyPosition);
    });
  }

  bool _cannotDetermineAdvisedSpeed(Journey? journey, JourneyPositionModel journeyPosition) =>
      journey == null || journeyPosition.currentPosition == null;

  void _handleUpdate(Journey? journey, JourneyPositionModel journeyPosition) {
    _currentPositionOrder = journeyPosition.currentPosition!.order;
    final advisedSpeedSegments = journey!.metadata.advisedSpeedSegments;
    _activeSegments = advisedSpeedSegments.appliesToOrder(_currentPositionOrder).toList();
    _activeLineSpeed = _lineSpeedViewModel.getResolvedSpeedForOrder(_currentPositionOrder).speed?.speed as SingleSpeed?;

    if (_activeSegments.length > 1) {
      _handleMultipleSegments();
    } else {
      _handleSingleSegment(_activeSegments.firstOrNull);
    }
  }

  void _handleMultipleSegments() {
    // idea is to reduce multi segment case to single case
    final nonEndingSegments = _activeSegments.where((segment) => segment.endOrder != _currentPositionOrder);
    if (nonEndingSegments.isEmpty) return;
    if (nonEndingSegments.length == 1) return _maybeStartAdvisedSpeed(nonEndingSegments.first);

    _log.warning('Received multiple advised speed segments for same position. Displaying first one!');
    _handleSingleSegment(nonEndingSegments.sorted((a, b) => a.compareTo(b)).first);
  }

  void _handleSingleSegment(AdvisedSpeedSegment? activeSegment) {
    // 1st priority: if we're active and on the end of the current segment => end AdvisedSpeed
    // 2nd priority: if active segment is null and we're in active state => cancel AdvisedSpeed
    // 3rd priority: if the activeSegment is not null => start or keep AdvisedSpeed

    if (activeSegment != null && activeSegment.endOrder == _currentPositionOrder) return _endAdvisedSpeed();
    if (activeSegment == null) return _cancelAdvisedSpeed();
    _maybeStartAdvisedSpeed(activeSegment);
  }

  void _endAdvisedSpeed() {
    if (modelValue is! Active) return;
    _log.fine('Setting AdvisedSpeedModel to end.');
    _emitModelWithTimerAndSounds(.end());
  }

  void _cancelAdvisedSpeed() {
    if (modelValue is! Active) return;
    _log.fine('Setting AdvisedSpeedModel to cancel.');
    _emitModelWithTimerAndSounds(.cancel());
  }

  void _maybeStartAdvisedSpeed(AdvisedSpeedSegment activeSegment) {
    _emitModelWithTimerAndSounds(.active(segment: activeSegment, lineSpeed: _activeLineSpeed));
  }

  void _emitModelWithTimerAndSounds(AdvisedSpeedModel updatedModel) {
    final soundCallback = _getSoundsCallback(updatedModel);
    _resetTimerIfNecessary(updatedModel);

    _addToNotificationVM(updatedModel, soundCallback);
    _rxModel.add(updatedModel);
  }

  VoidCallback? _getSoundsCallback(AdvisedSpeedModel updatedModel) {
    // play sounds if:
    // * Inactive / End / Cancel => Active  [Start sound]
    // * Active => End / Cancel [End Sound]
    // * Active => Active (different segment) [Start sound]
    final currentModel = modelValue;

    if (currentModel is! Active && updatedModel is Active) return _startSound.play;
    if (currentModel is! Active) return null;

    if (updatedModel is Cancel || updatedModel is End) return _endSound.play;

    if (updatedModel is Active && updatedModel.segment != currentModel.segment) return _startSound.play;
    return null;
  }

  void _resetTimerIfNecessary(AdvisedSpeedModel updatedModel) {
    if (updatedModel == modelValue) return;

    _setToInactiveTimer?.cancel();
    if (updatedModel is Cancel || updatedModel is End) _startSetToInactiveTimer();
  }

  void _startSetToInactiveTimer() {
    _setToInactiveTimer = Timer(Duration(seconds: _endOrCancelDisplaySeconds), () {
      _log.fine('Timer reached: Setting AdvisedSpeedModel to inactive.');
      _rxModel.add(AdvisedSpeedModel.inactive());
      _notificationVM.remove(type: .advisedSpeed);
    });
  }

  @override
  void journeyIdentificationChanged(_) {
    _rxModel.add(AdvisedSpeedModel.inactive());
    _setToInactiveTimer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _setToInactiveTimer?.cancel();
    _journeySubscription?.cancel();
    _rxModel.close();
  }

  void _addToNotificationVM(AdvisedSpeedModel updatedModel, VoidCallback? soundCallback) {
    if (updatedModel is Inactive) {
      _notificationVM.remove(type: .advisedSpeed);
    } else {
      _notificationVM.insert(type: .advisedSpeed, callback: soundCallback);
    }
  }
}
