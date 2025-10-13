import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/replacement_series_model.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ReplacementSeriesViewModel {
  ReplacementSeriesViewModel({
    required TrainJourneyViewModel trainJourneyViewModel,
    required JourneyPositionViewModel journeyPositionViewModel,
  }) : _trainJourneyViewModel = trainJourneyViewModel,
       _journeyPositionViewModel = journeyPositionViewModel {
    _initJourneySubscription();
    _initJourneyPositionSubscription();
    _initSettingsSubscription();
  }

  final TrainJourneyViewModel _trainJourneyViewModel;
  final JourneyPositionViewModel _journeyPositionViewModel;
  final List<StreamSubscription> _subscriptions = [];
  final _rxModel = BehaviorSubject<ReplacementSeriesModel?>.seeded(null);

  Stream<ReplacementSeriesModel?> get model => _rxModel.distinct();

  ReplacementSeriesModel? get modelValue => _rxModel.value;

  List<IllegalSpeedSegment> _illegalSpeedSegments = [];
  Journey? latestJourney;

  void _initJourneySubscription() {
    _subscriptions.add(
      _trainJourneyViewModel.journey.listen((data) {
        latestJourney = data;
        final currentBreakSeries = _trainJourneyViewModel.settingsValue.resolvedBreakSeries(latestJourney?.metadata);
        _calculateIllegalSpeedSegments(latestJourney, currentBreakSeries);
        _handleActiveSegment();
      }),
    );
  }

  void _initJourneyPositionSubscription() {
    _subscriptions.add(
      _journeyPositionViewModel.model.listen((position) {
        _handleActiveSegment();
      }),
    );
  }

  void _initSettingsSubscription() {
    _subscriptions.add(
      _trainJourneyViewModel.settings.listen((settings) {
        _calculateIllegalSpeedSegments(
          latestJourney,
          settings.resolvedBreakSeries(latestJourney?.metadata),
        );

        final currentModelValue = modelValue;
        if (currentModelValue is ReplacementSeriesAvailable &&
            settings.selectedBreakSeries == currentModelValue.segment.replacement) {
          // User selected the replacement series, clear notification
          _rxModel.add(ReplacementSeriesModel.selected(segment: currentModelValue.segment));
        } else if (currentModelValue is OriginalSeriesAvailable &&
            settings.selectedBreakSeries != currentModelValue.segment.replacement) {
          _rxModel.add(null);
        } else {
          _handleActiveSegment();
        }
      }),
    );
  }

  void _handleActiveSegment() {
    final position = _journeyPositionViewModel.modelValue;
    if (position?.currentPosition == null) return;

    final currentPosition = position!.currentPosition!;
    final currentBreakSeries = _trainJourneyViewModel.settingsValue.resolvedBreakSeries(latestJourney?.metadata);
    final currentModelValue = modelValue;

    final activeSegment = _activeIllegalSpeedSegment(currentBreakSeries, currentPosition);
    if (activeSegment != null && activeSegment.replacement != null) {
      // Show notification for replacement series
      _rxModel.add(ReplacementSeriesModel.replacement(segment: activeSegment));
    } else if (currentModelValue is ReplacementSeriesSelected &&
        currentPosition.order == currentModelValue.segment.end.order) {
      // Show notification that user reached the end of the segment
      _rxModel.add(ReplacementSeriesModel.original(segment: currentModelValue.segment));
    }
  }

  void _calculateIllegalSpeedSegments(Journey? journey, BreakSeries? breakSeries) {
    if (journey == null || breakSeries == null) {
      return;
    }

    _illegalSpeedSegments = _findIllegalSpeedSegments(journey, breakSeries);
  }

  IllegalSpeedSegment? _activeIllegalSpeedSegment(BreakSeries? currentBreakSeries, JourneyPoint currentPosition) =>
      _illegalSpeedSegments.firstWhereOrNull(
        (it) => it.start.order <= currentPosition.order && it.end.order >= currentPosition.order,
      );

  List<IllegalSpeedSegment> _findIllegalSpeedSegments(Journey journey, BreakSeries currentBreakSeries) {
    final illegalSegments = <IllegalSpeedSegment>[];

    final List<ServicePoint> servicePoints = journey.journeyPoints.whereType<ServicePoint>().toList();
    ServicePoint? lastServicePoint;

    ServicePoint? startServicePoint;
    var hasIllegalLineSpeed = false;
    final List<Iterable<TrainSeriesSpeed>> relevantSpeeds = [];

    final journeyPoints = journey.journeyPoints;
    for (int i = 0; i < journeyPoints.length - 1; i++) {
      final point = journeyPoints[i];
      if (point is ServicePoint) {
        // Remember last ServicePoint
        lastServicePoint = point;
      }

      // Check line speed
      final lineSpeed = journey.metadata.lineSpeeds[point.order];
      if (lineSpeed != null) {
        hasIllegalLineSpeed = _hasIllegalSpeedFor(lineSpeed, currentBreakSeries);
      }

      // Check local speed
      final hasIllegalLocalSpeed =
          point.localSpeeds != null && _hasIllegalSpeedFor(point.localSpeeds!, currentBreakSeries);

      final hasIllegalSpeed = hasIllegalLineSpeed || hasIllegalLocalSpeed;

      if (hasIllegalSpeed) {
        startServicePoint ??= lastServicePoint;

        if (point.localSpeeds != null) {
          relevantSpeeds.add(point.localSpeeds!);
        }
        if (lineSpeed != null) {
          relevantSpeeds.add(lineSpeed);
        }
      } else if (startServicePoint != null) {
        // end of illegal segment
        final endServicePoint = servicePoints.firstWhereOrNull((it) => it.order >= point.order) ?? servicePoints.last;
        final replacement = _possibleReplacementSeriesFor(
          relevantSpeeds,
          currentBreakSeries,
          journey.metadata.availableBreakSeries,
        );

        illegalSegments.add(
          IllegalSpeedSegment(
            start: startServicePoint,
            end: endServicePoint,
            original: currentBreakSeries,
            replacement: replacement,
          ),
        );
        startServicePoint = null;
        relevantSpeeds.clear();
      }
    }
    return illegalSegments;
  }

  bool _hasIllegalSpeedForAny(List<Iterable<TrainSeriesSpeed>> speeds, BreakSeries breakSeries) => speeds.any(
    (it) => _hasIllegalSpeedFor(it, breakSeries),
  );

  bool _hasIllegalSpeedFor(Iterable<TrainSeriesSpeed> speeds, BreakSeries breakSeries) =>
      speeds.speedFor(breakSeries.trainSeries, breakSeries: breakSeries.breakSeries)?.speed.isIllegal == true;

  BreakSeries? _possibleReplacementSeriesFor(
    List<Iterable<TrainSeriesSpeed>> speeds,
    BreakSeries currentBreakSeries,
    Set<BreakSeries> availableBreakSeries,
  ) {
    final validReplacementSeries = availableBreakSeries.validReplacementSeries(currentBreakSeries);

    for (final replacement in validReplacementSeries) {
      final hasIllegalSpeed = _hasIllegalSpeedForAny(speeds, replacement);
      if (!hasIllegalSpeed) {
        return replacement;
      }
    }

    return null;
  }

  void dispose() {
    for (final it in _subscriptions) {
      it.cancel();
    }
    _subscriptions.clear();
  }
}

extension _BreakSeriesSetX on Iterable<BreakSeries> {
  Iterable<BreakSeries> validReplacementSeries(BreakSeries current) =>
      where((it) {
        return it.trainSeries.canReplace(current.trainSeries) && it.breakSeries <= current.breakSeries;
      }).sorted(
        (a, b) {
          final trainSeriesComparison = a.trainSeries.index.compareTo(b.trainSeries.index);
          if (trainSeriesComparison != 0) return trainSeriesComparison;
          return a.breakSeries.compareTo(b.breakSeries);
        },
      ).reversed;
}
