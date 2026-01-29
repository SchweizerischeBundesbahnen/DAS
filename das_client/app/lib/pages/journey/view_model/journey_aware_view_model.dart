import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

abstract class JourneyAwareViewModel {
  JourneyAwareViewModel({JourneyTableViewModel? journeyTableViewModel})
    : journeyTableViewModel = journeyTableViewModel ?? DI.get<JourneyTableViewModel>() {
    _init();
  }

  final JourneyTableViewModel journeyTableViewModel;
  Journey? lastJourney;
  StreamSubscription? _journeySubscription;

  void _init() {
    _journeySubscription = journeyTableViewModel.journey.listen((journey) {
      final currentTrainIdentification = journey?.metadata.trainIdentification;
      if (currentTrainIdentification != lastJourney?.metadata.trainIdentification) {
        journeyIdentificationChanged(journey);
      } else {
        journeyUpdated(journey);
      }
      lastJourney = journey;
    });
  }

  void journeyUpdated(Journey? journey) {}

  void journeyIdentificationChanged(Journey? journey);

  @mustCallSuper
  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }
}
