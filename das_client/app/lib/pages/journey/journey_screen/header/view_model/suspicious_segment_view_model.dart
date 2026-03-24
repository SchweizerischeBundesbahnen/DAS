import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/model/suspicious_segment_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _logger = Logger('SuspiciousSegmentViewModel');

class SuspiciousSegmentViewModel extends JourneyAwareViewModel {
  SuspiciousSegmentViewModel({
    required super.journeyViewModel,
    required JourneyPositionViewModel journeyPositionViewModel,
    required NotificationPriorityQueueViewModel notificationVM,
  }) : _journeyPositionViewModel = journeyPositionViewModel,
       _notificationVM = notificationVM {
    _initJourneyPositionSubscription();
  }

  final JourneyPositionViewModel _journeyPositionViewModel;
  final NotificationPriorityQueueViewModel _notificationVM;

  StreamSubscription<JourneyPositionModel>? _journeyPositionSubscription;

  final BehaviorSubject<SuspiciousSegmentModel> _rxSubject = BehaviorSubject.seeded(SuspiciousSegmentHidden());

  JourneyPoint? _lastCurrentPosition;
  bool _dismissed = false;

  Stream<SuspiciousSegmentModel> get model => _rxSubject.stream.distinct();

  SuspiciousSegmentModel get modelValue => _rxSubject.value;

  /// Manually dismiss the notification. Remains hidden until
  /// suspicious segments are reported by a TMS VAD update.
  void dismiss() {
    _logger.fine('Suspicious segment notification dismissed by user.');
    _dismissed = true;
    _emitModel(SuspiciousSegmentHidden());
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _lastCurrentPosition = null;
    _dismissed = false;
    _calculateAndEmitModel(journey: journey, currentPosition: null);
  }

  @override
  void journeyUpdated(Journey? journey) {
    final currentSegments = journey?.metadata.suspiciousSegments ?? [];
    final lastSegments = lastJourney?.metadata.suspiciousSegments ?? [];

    final newSegmentAdded =
        currentSegments.length > lastSegments.length || !ListEquality().equals(currentSegments, lastSegments);
    final allSegmentsResolved = currentSegments.isEmpty && lastSegments.isNotEmpty;

    if (newSegmentAdded) {
      _logger.fine('New suspicious segment detected.');
      _dismissed = false;
      _calculateAndEmitModel(journey: journey, currentPosition: _lastCurrentPosition);
    } else if (allSegmentsResolved) {
      _logger.fine('All suspicious segments resolved.');
      _emitModel(SuspiciousSegmentHidden());
    }
  }

  @override
  void dispose() {
    _journeyPositionSubscription?.cancel();
    _rxSubject.close();
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

  void _emitModel(SuspiciousSegmentModel model) {
    _rxSubject.add(model);
    if (model is SuspiciousSegmentVisible) {
      _notificationVM.insert(type: .suspiciousSegment);
    } else {
      _notificationVM.remove(type: .suspiciousSegment);
    }
  }

  void _calculateAndEmitModel({Journey? journey, JourneyPoint? currentPosition}) {
    final suspiciousSegments = journey?.metadata.suspiciousSegments ?? [];

    if (suspiciousSegments.isEmpty) {
      _logger.fine('No suspicious segments – emitting hidden.');
      _emitModel(SuspiciousSegmentHidden());
      return;
    }

    if (_dismissed) {
      _logger.fine('Notification was dismissed – keeping hidden.');
      return;
    }

    if (_hasPassedAllSuspiciousSegments(suspiciousSegments, currentPosition, journey)) {
      _logger.fine('All suspicious segments have been passed – emitting hidden.');
      _emitModel(SuspiciousSegmentHidden());
      return;
    }

    _logger.fine('Suspicious segments present – emitting visible.');
    _emitModel(SuspiciousSegmentVisible());
  }

  bool _hasPassedAllSuspiciousSegments(
    List<SuspiciousSegment> suspiciousSegments,
    JourneyPoint? currentPosition,
    Journey? journey,
  ) {
    if (currentPosition == null) return false;
    if (currentPosition == journey?.metadata.journeyStart) return false;

    final maxEndOrder = suspiciousSegments.map((s) => s.endOrder).nonNulls.maxOrNull;

    if (maxEndOrder == null) return false;

    return currentPosition.order > maxEndOrder;
  }
}
