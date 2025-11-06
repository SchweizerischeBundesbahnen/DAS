import 'dart:async';

import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/illegal_speed_segment.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/replacement_series_model.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('ReplacementSeriesViewModel');

class ReplacementSeriesViewModel {
  ReplacementSeriesViewModel({
    required JourneyTableViewModel journeyTableViewModel,
    required JourneyPositionViewModel journeyPositionViewModel,
  }) : _journeyTableViewModel = journeyTableViewModel,
       _journeyPositionViewModel = journeyPositionViewModel {
    _initJourneySubscription();
    _initJourneyPositionSubscription();
    _initSettingsSubscription();
  }

  final JourneyTableViewModel _journeyTableViewModel;
  final JourneyPositionViewModel _journeyPositionViewModel;
  final List<StreamSubscription> _subscriptions = [];
  final _rxModel = BehaviorSubject<ReplacementSeriesModel?>.seeded(null);

  Stream<ReplacementSeriesModel?> get model => _rxModel.distinct();

  ReplacementSeriesModel? get modelValue => _rxModel.value;

  List<IllegalSpeedSegment> _illegalSpeedSegments = [];
  Journey? _latestJourney;

  void _initJourneySubscription() {
    _subscriptions.add(
      _journeyTableViewModel.journey.listen((data) {
        _latestJourney = data;
        final currentBreakSeries = _journeyTableViewModel.settingsValue.resolvedBreakSeries(_latestJourney?.metadata);
        _calculateIllegalSpeedSegments(currentBreakSeries);
        _calculateActiveSegmentAndUpdateState();
      }),
    );
  }

  void _initJourneyPositionSubscription() {
    _subscriptions.add(
      _journeyPositionViewModel.model.listen((position) {
        _calculateActiveSegmentAndUpdateState();
      }),
    );
  }

  void _initSettingsSubscription() {
    _subscriptions.add(
      _journeyTableViewModel.settings.listen((settings) {
        _calculateIllegalSpeedSegments(
          settings.resolvedBreakSeries(_latestJourney?.metadata),
        );

        final currentModelValue = modelValue;
        if (currentModelValue is ReplacementSeriesAvailable) {
          if (settings.selectedBreakSeries == currentModelValue.segment.replacement) {
            _rxModel.add(ReplacementSeriesModel.selected(segment: currentModelValue.segment));
            _log.info('User selected replacement series ${currentModelValue.segment.replacement?.name}');
          } else if (settings.selectedBreakSeries != currentModelValue.segment.original) {
            _rxModel.add(null);
            _log.info('User selected a different break series, clearing replacement series notification');
            _calculateActiveSegmentAndUpdateState();
          }
        } else if (currentModelValue is OriginalSeriesAvailable &&
            settings.selectedBreakSeries != currentModelValue.segment.replacement) {
          _rxModel.add(null);
        } else {
          _calculateActiveSegmentAndUpdateState();
        }
      }),
    );
  }

  void _calculateActiveSegmentAndUpdateState() {
    final position = _journeyPositionViewModel.modelValue;

    final currentBreakSeries = _journeyTableViewModel.settingsValue.resolvedBreakSeries(_latestJourney?.metadata);
    final currentModelValue = modelValue;

    final segmentWithoutReplacement = _illegalSpeedSegments.firstWhereOrNull((it) => it.replacement == null);

    if (segmentWithoutReplacement != null) {
      _rxModel.add(ReplacementSeriesModel.none(segment: segmentWithoutReplacement));
      _log.info(
        'Found illegal speed segment for ${segmentWithoutReplacement.original.name} without replacement series starting from ${segmentWithoutReplacement.start.name}',
      );
      return;
    } else if (currentModelValue is NoReplacementSeries) {
      _rxModel.add(null);
    }

    if (position.currentPosition == null) return;

    final currentPosition = position.currentPosition!;
    final activeSegment = _activeIllegalSpeedSegment(currentBreakSeries, currentPosition);

    if (activeSegment != null && activeSegment.replacement != null) {
      // Show notification for replacement series
      _rxModel.add(ReplacementSeriesModel.replacement(segment: activeSegment));
      _log.info(
        'Suggesting replacement series ${activeSegment.replacement?.name} from ${activeSegment.start.name} to ${activeSegment.end.name}',
      );
    } else if (currentModelValue is ReplacementSeriesSelected &&
        currentPosition.order >= currentModelValue.segment.end.order) {
      // Show notification that user reached the end of the segment
      _rxModel.add(ReplacementSeriesModel.original(segment: currentModelValue.segment));
      _log.info(
        'User reached end of replacement segment, suggesting original series ${currentModelValue.segment.original.name}',
      );
    } else if (currentModelValue is ReplacementSeriesAvailable &&
        currentPosition.order >= currentModelValue.segment.end.order) {
      // User did not select the replacement series and reached the end of the segment, clear notification
      _rxModel.add(null);
      _log.info('User reached end of segment without selecting replacement series');
    } else if (currentModelValue is ReplacementSeriesAvailable && activeSegment == null) {
      // No active segment anymore, clear notification
      _rxModel.add(null);
      _log.info('No active segment, clearing replacement series notification');
    }
  }

  IllegalSpeedSegment? _activeIllegalSpeedSegment(BreakSeries? currentBreakSeries, JourneyPoint currentPosition) =>
      _illegalSpeedSegments.firstWhereOrNull(
        (it) => it.start.order <= currentPosition.order && it.end.order > currentPosition.order,
      );

  ///
  /// Checks every journey point for illegal speeds in either line speeds or local speeds.
  /// If an illegal speed is found, a new [IllegalSpeedSegment] is started.
  /// [IllegalSpeedSegment] are always constructed from [ServicePoint] to [ServicePoint].
  /// A Replacement [BreakSeries] that is valid for all journey points is calculated.
  ///
  void _calculateIllegalSpeedSegments(BreakSeries? breakSeries) {
    final journey = _latestJourney;
    _illegalSpeedSegments = [];
    if (journey == null || breakSeries == null) {
      return;
    }

    final List<ServicePoint> servicePoints = journey.journeyPoints.whereType<ServicePoint>().toList();
    ServicePoint? latestServicePoint;

    ServicePoint? startServicePoint;
    var hasIllegalLineSpeed = false;
    final List<Iterable<TrainSeriesSpeed>> relevantSpeeds = [];

    final journeyPoints = journey.journeyPoints;
    for (final point in journeyPoints) {
      if (point is ServicePoint) latestServicePoint = point;

      // Check line speed
      final lineSpeeds = journey.metadata.lineSpeeds[point.order];
      if (lineSpeeds != null) {
        hasIllegalLineSpeed = _hasIllegalSpeedFor(lineSpeeds, breakSeries);
      }

      // Check local speed
      final hasIllegalLocalSpeed = point.localSpeeds != null && _hasIllegalSpeedFor(point.localSpeeds!, breakSeries);

      final hasIllegalSpeed = hasIllegalLineSpeed || hasIllegalLocalSpeed;

      if (hasIllegalSpeed) {
        startServicePoint ??= latestServicePoint;

        if (point.localSpeeds != null) {
          relevantSpeeds.add(point.localSpeeds!);
        }
        if (lineSpeeds != null) {
          relevantSpeeds.add(lineSpeeds);
        }
      } else if (startServicePoint != null) {
        // end of illegal segment
        final endServicePoint = servicePoints.firstWhereOrNull((it) => it.order >= point.order) ?? servicePoints.last;
        final replacement = _replacementSeriesFor(
          relevantSpeeds,
          breakSeries,
          journey.metadata.availableBreakSeries,
        );

        _illegalSpeedSegments.add(
          IllegalSpeedSegment(
            start: startServicePoint,
            end: endServicePoint,
            original: breakSeries,
            replacement: replacement,
          ),
        );
        startServicePoint = null;
        relevantSpeeds.clear();
      }
    }

    _log.fine('Found ${_illegalSpeedSegments.length} IllegalSpeedSegments for $breakSeries');
  }

  bool _hasIllegalSpeedForAny(List<Iterable<TrainSeriesSpeed>> speeds, BreakSeries breakSeries) => speeds.any(
    (it) => _hasIllegalSpeedFor(it, breakSeries),
  );

  bool _hasIllegalSpeedFor(Iterable<TrainSeriesSpeed> speeds, BreakSeries breakSeries) =>
      speeds.speedFor(breakSeries.trainSeries, breakSeries: breakSeries.breakSeries)?.speed.isIllegal == true;

  BreakSeries? _replacementSeriesFor(
    List<Iterable<TrainSeriesSpeed>> speeds,
    BreakSeries currentBreakSeries,
    Set<BreakSeries> availableBreakSeries,
  ) {
    final validReplacementSeries = availableBreakSeries.validReplacementSeries(currentBreakSeries);
    return validReplacementSeries.firstWhereOrNull((it) => !_hasIllegalSpeedForAny(speeds, it));
  }

  void dispose() {
    for (final it in _subscriptions) {
      it.cancel();
    }
    _subscriptions.clear();
    _rxModel.close();
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
