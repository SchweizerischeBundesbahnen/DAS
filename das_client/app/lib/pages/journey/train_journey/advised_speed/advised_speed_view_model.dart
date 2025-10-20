import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('AdvisedSpeedViewModel');

class AdvisedSpeedViewModel {
  AdvisedSpeedViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel?> journeyPositionStream,
  }) {
    _initJourneyStreamSubscription(journeyStream, journeyPositionStream);
  }

  static Sound get _startSound => DI.get<DASSounds>().advisedSpeedStart;

  static Sound get _endSound => DI.get<DASSounds>().advisedSpeedEnd;

  final _endOrCancelDisplaySeconds = DI.get<TimeConstants>().advisedSpeedEndDisplaySeconds;

  Timer? _setToInactiveTimer;

  StreamSubscription<(Journey?, JourneyPositionModel?)>? _journeySubscription;

  final _rxModel = BehaviorSubject<AdvisedSpeedModel>.seeded(AdvisedSpeedModel.inactive());

  Stream<AdvisedSpeedModel> get model => _rxModel.distinct();

  AdvisedSpeedModel get modelValue => _rxModel.value;

  void dispose() {
    _setToInactiveTimer?.cancel();
    _journeySubscription?.cancel();
    _rxModel.close();
  }

  void _initJourneyStreamSubscription(
    Stream<Journey?> journeyStream,
    Stream<JourneyPositionModel?> journeyPositionStream,
  ) {
    _journeySubscription = CombineLatestStream.combine2(journeyStream, journeyPositionStream, (a, b) => (a, b)).listen((
      data,
    ) {
      final journey = data.$1;
      final journeyPosition = data.$2;
      if (_cannotDetermineAdvisedSpeed(journey, journeyPosition)) return;

      _handleJourneyUpdate(journey, journeyPosition);
    });
  }

  bool _cannotDetermineAdvisedSpeed(Journey? journey, JourneyPositionModel? journeyPosition) =>
      journey == null || journeyPosition?.currentPosition == null;

  void _handleJourneyUpdate(Journey? journey, JourneyPositionModel? journeyPosition) {
    final currentPositionOrder = journeyPosition!.currentPosition!.order;
    final advisedSpeedSegments = journey!.metadata.advisedSpeedSegments;
    final activeSegments = advisedSpeedSegments.appliesToOrder(currentPositionOrder).toList();

    if (activeSegments.length > 1) return _handleMultipleSegments(activeSegments, currentPositionOrder);

    final currentModel = modelValue;
    final activeSegment = activeSegments.firstOrNull;

    // 1st priority: if we're active and on the end of the current segment => end AdvisedSpeed
    // 2nd priority: if active segment is null and we're in active state => cancel AdvisedSpeed
    // 3rd priority: if the activeSegment is not null => start or keep AdvisedSpeed
    if (currentModel is Active && currentModel.segment.endOrder == currentPositionOrder) return _endAdvisedSpeed();
    if (currentModel is Active && activeSegment == null) return _cancelAdvisedSpeed();
    if (activeSegment != null) return _startOrKeepAdvisedSpeed(activeSegment);
  }

  void _endAdvisedSpeed() => _emitModelWithTimerAndSounds(AdvisedSpeedModel.end());

  void _cancelAdvisedSpeed() => _emitModelWithTimerAndSounds(AdvisedSpeedModel.cancel());

  void _startOrKeepAdvisedSpeed(AdvisedSpeedSegment activeSegment) =>
      _emitModelWithTimerAndSounds(AdvisedSpeedModel.active(segment: activeSegment));

  void _handleMultipleSegments(List<AdvisedSpeedSegment> activeSegments, int currentPositionOrder) {
    final nonEndingSegments = activeSegments.where((segment) => segment.endOrder != currentPositionOrder);
    if (nonEndingSegments.isEmpty) return;
    if (nonEndingSegments.length == 1) return _startOrKeepAdvisedSpeed(nonEndingSegments.first);

    _log.warning('Received multiple advised speed segments for same position. Displaying first one!');
    _emitModelWithTimerAndSounds(
      AdvisedSpeedModel.active(segment: nonEndingSegments.sorted((a, b) => a.compareTo(b)).first),
    );
  }

  void _emitModelWithTimerAndSounds(AdvisedSpeedModel updatedModel) {
    _playSoundsIfNecessary(updatedModel);
    _resetTimerIfNecessary(updatedModel);

    _rxModel.add(updatedModel);
  }

  Future<void> _playSoundsIfNecessary(AdvisedSpeedModel updatedModel) async {
    // play sounds if:
    // * Inactive / End / Cancel => Active  [Start sound]
    // * Active => End / Cancel [End Sound]
    // * Active => Active (different segment) [Start sound]
    final currentModel = modelValue;

    if (currentModel is! Active && updatedModel is Active) return _startSound.play();
    if (currentModel is! Active) return;

    if (updatedModel is Cancel || updatedModel is End) return _endSound.play();
    if (updatedModel is Active && updatedModel != currentModel) return _startSound.play();
  }

  void _resetTimerIfNecessary(AdvisedSpeedModel updatedModel) {
    _setToInactiveTimer?.cancel();
    if (updatedModel is Cancel || updatedModel is End) _startResetToInactiveTimer();
  }

  void _startResetToInactiveTimer() {
    _setToInactiveTimer?.cancel();
    _setToInactiveTimer = Timer(Duration(seconds: _endOrCancelDisplaySeconds), () {
      _rxModel.add(AdvisedSpeedModel.inactive());
    });
  }
}
