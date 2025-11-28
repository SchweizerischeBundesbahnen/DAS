import 'dart:async';

import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:collection/collection.dart';
import 'package:formation/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class BreakLoadSlipViewModel {
  BreakLoadSlipViewModel({
    required JourneyTableViewModel journeyTableViewModel,
    required FormationRepository formationRepository,
    required JourneyPositionViewModel journeyPositionViewModel,
  }) : _journeyTableViewModel = journeyTableViewModel,
       _formationRepository = formationRepository,
       _journeyPositionViewModel = journeyPositionViewModel {
    _init();
  }

  final JourneyTableViewModel _journeyTableViewModel;
  final FormationRepository _formationRepository;
  final JourneyPositionViewModel _journeyPositionViewModel;
  Journey? _latestJourney;
  JourneyPositionModel? _latestPosition;

  StreamSubscription? _journeySubscription;
  StreamSubscription? _journeyPositionSubscription;
  StreamSubscription? _formationSubscription;

  final _rxFormation = BehaviorSubject<Formation?>.seeded(null);
  final _rxFormationRun = BehaviorSubject<FormationRun?>.seeded(null);

  Stream<Formation?> get formation => _rxFormation.stream.distinct();

  Stream<FormationRun?> get formationRun => _rxFormationRun.distinct();

  Stream<JourneySettings?> get settings => _journeyTableViewModel.settings;

  Formation? get formationValue => _rxFormation.value;

  FormationRun? get formationRunValue => _rxFormationRun.value;

  void _init() {
    _journeySubscription = _journeyTableViewModel.journey.listen((journey) {
      if (_latestJourney?.metadata.trainIdentification != journey?.metadata.trainIdentification) {
        _subscribeToFormation(journey?.metadata.trainIdentification);
      }
      _latestJourney = journey;
      _emitFormationRun();
    });
    _journeyPositionSubscription = _journeyPositionViewModel.model.listen((position) {
      _latestPosition = position;
      _emitFormationRun();
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
            _emitFormationRun();
          });
    }
  }

  void _emitFormationRun() {
    _rxFormationRun.add(_calculateActiveFormationRun());
  }

  FormationRun? _calculateActiveFormationRun() {
    final position = _latestPosition;
    final currentFormation = formationValue;
    if (position == null ||
        position.currentPosition == null ||
        currentFormation == null ||
        currentFormation.formationRuns.isEmpty) {
      return null;
    }

    return currentFormation.formationRuns.reversed.firstWhere((it) {
      final startServicePoint = _resolveServicePoint(it.tafTapLocationReferenceStart);
      final endServicePoint = _resolveServicePoint(it.tafTapLocationReferenceEnd);
      if (startServicePoint == null || endServicePoint == null) return false;

      return position.currentPosition!.order >= startServicePoint.order &&
          position.currentPosition!.order <= endServicePoint.order;
    }, orElse: () => currentFormation.formationRuns.first);
  }

  ServicePoint? _resolveServicePoint(String tafTapLocationCode) {
    if (_latestJourney == null) return null;

    return _latestJourney!.journeyPoints.whereType<ServicePoint>().firstWhereOrNull(
      (it) => it.locationCode == tafTapLocationCode,
    );
  }

  bool get isActiveFormationRun => _calculateActiveFormationRun() == formationRunValue;

  bool activeFormationRunHasDifferentBreakSeries() {
    final selectedBreakSeries = _journeyTableViewModel.settingsValue.resolvedBreakSeries(_latestJourney?.metadata);
    final formationRunBreakSeries = _resolveBreakSeries(formationRunValue);
    return formationRunBreakSeries != null && formationRunBreakSeries != selectedBreakSeries;
  }

  void applyActiveFormationRunBreakSeries() {
    final formationRunBreakSeries = _resolveBreakSeries(formationRunValue);
    if (formationRunBreakSeries != null) {
      _journeyTableViewModel.updateBreakSeries(formationRunBreakSeries);
    }
  }

  BreakSeries? _resolveBreakSeries(FormationRun? formationRun) {
    final trainSeries = TrainSeries.fromOptional(formationRun?.trainCategoryCode);
    final breakSeries = formationRun?.brakedWeightPercentage;

    return (trainSeries != null && breakSeries != null)
        ? BreakSeries(trainSeries: trainSeries, breakSeries: breakSeries)
        : null;
  }

  String resolveStationName(String tafTapLocationCode) {
    if (_latestJourney == null) return tafTapLocationCode;

    final matchedServicePoint = _latestJourney!.journeyPoints.whereType<ServicePoint>().firstWhereOrNull(
      (it) => it.locationCode == tafTapLocationCode,
    );
    return matchedServicePoint?.name ?? tafTapLocationCode;
  }

  String resolveRailwayUndertaking(String companyCode) {
    final ru = RailwayUndertaking.fromCompanyCode(companyCode);
    return ru != RailwayUndertaking.unknown ? ru.name : companyCode;
  }

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
    _formationSubscription?.cancel();
    _formationSubscription = null;
    _journeyPositionSubscription?.cancel();
    _journeyPositionSubscription = null;
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
