import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

abstract class JourneyAwareViewModel {
  JourneyAwareViewModel({JourneyViewModel? journeyViewModel})
    : journeyViewModel = journeyViewModel ?? DI.get<JourneyViewModel>() {
    _init();
  }

  final JourneyViewModel journeyViewModel;
  Journey? lastJourney;
  StreamSubscription? _journeySubscription;

  void _init() {
    _journeySubscription = journeyViewModel.journey.listen((journey) {
      final lastTrainIdentification = lastJourney?.metadata.trainIdentification;
      lastJourney = journey;
      if (journey?.metadata.trainIdentification != lastTrainIdentification) {
        onJourneyChanged(journey);
      } else {
        onJourneyUpdated(journey);
      }
    });
  }

  /// Called when a journey is updated
  void onJourneyUpdated(Journey? journey) {}

  /// Called when a new journey is emitted the first time
  void onJourneyChanged(Journey? journey) {}

  @mustCallSuper
  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }
}
