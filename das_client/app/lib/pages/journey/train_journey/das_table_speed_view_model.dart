import 'dart:async';
import 'dart:math';

import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class DASTableSpeedViewModel {
  DASTableSpeedViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<TrainJourneySettings> settingsStream,
  }) {
    _init(journeyStream, settingsStream);
  }

  late StreamSubscription<Journey?> _journeySubscription;
  late StreamSubscription<TrainJourneySettings> _settingsSubscription;

  TrainJourneySettings? _settings;
  Journey? _journey;

  SingleSpeed? previousLineSpeed(int rowIndex) {
    if (_journey == null || _settings == null) return null;

    final currentBreakSeries = _settings!.resolvedBreakSeries(_journey!.metadata);
    final end = min(_journey!.data.length, rowIndex);
    final previousSpeeds = _journey!.data
        .getRange(0, end)
        .map((d) => d.speeds.speedFor(currentBreakSeries?.trainSeries, breakSeries: currentBreakSeries?.breakSeries))
        .nonNulls
        .map((trainSeriesSpeed) => trainSeriesSpeed.speed)
        .whereType<SingleSpeed>();

    return previousSpeeds.lastOrNull;
  }

  SingleSpeed? previousCalculatedSpeed(int rowIndex) {
    if (_journey == null) return null;

    final end = min(_journey!.data.length, rowIndex);
    final previousData = _journey!.data.getRange(0, end);

    final servicePoints = previousData.whereType<ServicePoint>().toList();

    final previousCalculatedSpeed = servicePoints.map((sP) => sP.calculatedSpeed).nonNulls;
    return previousCalculatedSpeed.lastOrNull;
  }

  void _init(Stream<Journey?> journeyStream, Stream<TrainJourneySettings> settingsStream) {
    _journeySubscription = journeyStream.listen((journey) {
      _journey = journey;
    });
    _settingsSubscription = settingsStream.listen((settings) {
      _settings = settings;
    });
  }

  void dispose() {
    _settingsSubscription.cancel();
    _journeySubscription.cancel();
  }
}
