import 'dart:async';

import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:formation/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class BreakLoadSlipViewModel {
  BreakLoadSlipViewModel({
    required JourneyTableViewModel journeyTableViewModel,
    required FormationRepository formationRepository,
  }) : _journeyTableViewModel = journeyTableViewModel,
       _formationRepository = formationRepository {
    _init();
  }

  final JourneyTableViewModel _journeyTableViewModel;
  final FormationRepository _formationRepository;
  Journey? _latestJourney;

  StreamSubscription? _journeySubscription;
  StreamSubscription? _formationSubscription;

  final _rxFormation = BehaviorSubject<Formation?>.seeded(null);
  final _rxFormationRun = BehaviorSubject<FormationRun?>.seeded(null);

  Stream<Formation?> get formation => _rxFormation.stream;
  Stream<FormationRun?> get formationRun => _rxFormationRun.stream;

  Formation? get formationValue => _rxFormation.value;
  FormationRun? get formationRunValue => _rxFormationRun.value;

  void _init() {
    _journeySubscription = _journeyTableViewModel.journey.listen((journey) {
      if (_latestJourney?.metadata.trainIdentification != journey?.metadata.trainIdentification) {
        _subscribeToFormation(journey?.metadata.trainIdentification);
      }
      _latestJourney = journey;
    });
  }

  void _subscribeToFormation(TrainIdentification? trainIdentification) {
    _formationSubscription?.cancel();
    _rxFormation.add(null);
    _rxFormationRun.add(null);

    if (trainIdentification != null) {
      _formationSubscription = _formationRepository
          .watchFormation(trainIdentification.trainNumber, trainIdentification.ru.companyCode, trainIdentification.date)
          .listen((formation) {
            _rxFormation.add(formation);
            _rxFormationRun.add(formation?.formationRuns.firstOrNull);
          });
    }
  }

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
    _formationSubscription?.cancel();
    _formationSubscription = null;
  }

  void previous() {
    final formation = formationValue;
    final activeFormationRun = formationRunValue;
    if (formation == null || activeFormationRun == null) return;

    final currentIndex = formation.formationRuns.indexOf(activeFormationRun);
    if (currentIndex != -1 && currentIndex > 0) {
      _rxFormationRun.add(formation.formationRuns[currentIndex - 1]);
    }
  }

  void next() {
    final formation = formationValue;
    final activeFormationRun = formationRunValue;
    if (formation == null || activeFormationRun == null) return;

    final currentIndex = formation.formationRuns.indexOf(activeFormationRun);
    if (currentIndex != -1 && currentIndex < formation.formationRuns.length - 1) {
      _rxFormationRun.add(formation.formationRuns[currentIndex + 1]);
    }
  }
}
