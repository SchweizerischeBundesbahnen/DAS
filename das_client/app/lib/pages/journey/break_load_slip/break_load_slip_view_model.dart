import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/break_load_slip_modal/break_load_slip_modal_builder.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_x/component.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('BreakLoadSlipViewModel');

class BreakLoadSlipViewModel {
  static const _formationUpdateInterval = Duration(minutes: 2);

  BreakLoadSlipViewModel({
    required JourneyTableViewModel journeyTableViewModel,
    required FormationRepository formationRepository,
    required JourneyPositionViewModel journeyPositionViewModel,
    DetailModalViewModel? detailModalViewModel,
    ConnectivityManager? connectivityManager,
    bool checkForUpdates = false,
  }) : _journeyTableViewModel = journeyTableViewModel,
       _formationRepository = formationRepository,
       _journeyPositionViewModel = journeyPositionViewModel,
       _detailModalViewModel = detailModalViewModel,
       _connectivityManager = connectivityManager,
       _checkForUpdates = checkForUpdates {
    _init();
  }

  final JourneyTableViewModel _journeyTableViewModel;
  final FormationRepository _formationRepository;
  final JourneyPositionViewModel _journeyPositionViewModel;
  final DetailModalViewModel? _detailModalViewModel;
  final ConnectivityManager? _connectivityManager;
  final bool _checkForUpdates;

  final Sound _breakSlipUpdatedSound = DI.get<DASSounds>().breakSlipUpdated;

  Journey? _latestJourney;
  JourneyPositionModel? _latestPosition;
  bool _openFullscreen = true;
  bool _skipFirstUpdate = true;

  StreamSubscription? _journeySubscription;
  StreamSubscription? _journeyPositionSubscription;
  StreamSubscription? _formationSubscription;
  StreamSubscription? _connectivitySubscription;
  Timer? _formationUpdateTimer;

  final _rxFormation = BehaviorSubject<Formation?>.seeded(null);
  final _rxFormationRun = BehaviorSubject<FormationRunChange?>.seeded(null);
  final _rxFormationChanged = BehaviorSubject<bool>.seeded(false);

  Stream<Formation?> get formation => _rxFormation.stream.distinct();

  Stream<FormationRunChange?> get formationRun => _rxFormationRun.distinct();

  Stream<bool> get formationChanged => _rxFormationChanged.distinct();

  Stream<JourneySettings?> get settings => _journeyTableViewModel.settings;

  Formation? get formationValue => _rxFormation.value;

  FormationRunChange? get formationRunValue => _rxFormationRun.value;

  bool get formationChangedValue => _rxFormationChanged.value;

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
    if (_checkForUpdates) {
      _formationUpdateTimer = Timer.periodic(_formationUpdateInterval, (_) => _checkForFormationUpdates());
    }
    _connectivitySubscription = _connectivityManager?.onConnectivityChanged.listen((state) {
      if (state) _checkForFormationUpdates();
    });
  }

  void _checkForFormationUpdates() {
    if (_skipFirstUpdate) {
      _skipFirstUpdate = false;
      return;
    }

    final trainIdentification = _latestJourney?.metadata.trainIdentification;
    if (trainIdentification != null) {
      _formationRepository.loadFormation(
        trainIdentification.trainNumber,
        trainIdentification.ru.companyCode,
        trainIdentification.operatingDay ?? trainIdentification.date,
      );
    }
  }

  void _subscribeToFormation(TrainIdentification? trainIdentification) {
    _formationSubscription?.cancel();
    _rxFormation.add(null);
    _rxFormationRun.add(null);

    if (trainIdentification != null) {
      _formationSubscription = _formationRepository
          .watchFormation(
            operationalTrainNumber: trainIdentification.trainNumber,
            company: trainIdentification.ru.companyCode,
            operationalDay: trainIdentification.operatingDay ?? trainIdentification.date,
          )
          .listen((formation) {
            final formationChanged = formationValue != null;

            _rxFormation.add(formation);
            _changeOpenFullscreenFlag(true);
            _emitFormationRun();

            if (formationChanged) {
              _rxFormationChanged.add(true);

              if (_checkForUpdates) {
                _breakSlipUpdatedSound.play();
              }
            }
          });
    }
  }

  FormationRunChange? _generateFormationRuneChange(FormationRun? formationRun) {
    if (formationRun == null) return null;

    final index = formationValue?.formationRuns.indexOf(formationRun);
    final previousIndex = (index != null && index > 0) ? index - 1 : null;
    final previousFormationRun = (previousIndex != null && formationValue != null)
        ? formationValue!.formationRuns[previousIndex]
        : null;

    return FormationRunChange(formationRun: formationRun, previousFormationRun: previousFormationRun);
  }

  void _emitFormationRun() {
    final newActiveFormationRun = _calculateActiveFormationRun();
    if (newActiveFormationRun == formationRunValue?.formationRun) return;

    _log.info('Active formation run changed to $newActiveFormationRun}');
    _changeOpenFullscreenFlag(true);
    _rxFormationRun.add(_generateFormationRuneChange(newActiveFormationRun));
  }

  FormationRun? _calculateActiveFormationRun() {
    final position = _latestPosition;
    final currentFormation = formationValue;
    if (currentFormation == null || currentFormation.formationRuns.isEmpty) {
      return null;
    }

    if (position == null || position.currentPosition == null) {
      return currentFormation.formationRuns.first;
    }

    return currentFormation.formationRuns.reversed.firstWhere((it) {
      final startServicePoint = _resolveServicePoint(it.tafTapLocationReferenceStart);
      final endServicePoint = _resolveServicePoint(it.tafTapLocationReferenceEnd);
      if (startServicePoint != null && endServicePoint != null) {
        return position.currentPosition!.order >= startServicePoint.order &&
            position.currentPosition!.order <= endServicePoint.order;
      } else if (startServicePoint != null) {
        return position.currentPosition!.order >= startServicePoint.order;
      } else if (endServicePoint != null) {
        return position.currentPosition!.order <= endServicePoint.order;
      }
      return false;
    }, orElse: () => currentFormation.formationRuns.first);
  }

  ServicePoint? _resolveServicePoint(String tafTapLocationCode) {
    if (_latestJourney == null) return null;

    final servicePoints = _latestJourney!.journeyPoints.whereType<ServicePoint>().where(
      (it) => it.locationCode == tafTapLocationCode,
    );

    if (servicePoints.length > 1) {
      return servicePoints.firstWhereOrNull((it) => it.isStop) ?? servicePoints.first;
    }

    return servicePoints.firstOrNull;
  }

  bool get isActiveFormationRun => _calculateActiveFormationRun() == formationRunValue?.formationRun;

  bool isJourneyAndActiveFormationRunBreakSeriesDifferent() {
    final selectedBreakSeries = _journeyTableViewModel.settingsValue.resolvedBreakSeries(_latestJourney?.metadata);
    final formationRunBreakSeries = _resolveBreakSeries(formationRunValue?.formationRun);
    return formationRunBreakSeries != null && formationRunBreakSeries != selectedBreakSeries;
  }

  void updateJourneyBreakSeriesFromActiveFormationRun() {
    final formationRunBreakSeries = _resolveBreakSeries(formationRunValue?.formationRun);
    if (formationRunBreakSeries != null) {
      _journeyTableViewModel.updateBreakSeries(formationRunBreakSeries);
    }
  }

  BreakSeries? _resolveBreakSeries(FormationRun? formationRun) {
    final trainSeries = TrainSeries.fromOptional(formationRun?.trainCategoryCode);
    final breakSeries = formationRun?.brakedWeightPercentage;

    return trainSeries != null && breakSeries != null
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

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
    _formationSubscription?.cancel();
    _formationSubscription = null;
    _journeyPositionSubscription?.cancel();
    _journeyPositionSubscription = null;
    _rxFormation.close();
    _rxFormationRun.close();
    _formationUpdateTimer?.cancel();
    _formationUpdateTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void previous() {
    final formation = formationValue;
    final activeFormationRun = formationRunValue;
    if (formation == null || activeFormationRun == null) return;

    final currentIndex = formation.formationRuns.indexOf(activeFormationRun.formationRun);
    if (currentIndex != -1 && currentIndex > 0) {
      _rxFormationRun.add(_generateFormationRuneChange(formation.formationRuns[currentIndex - 1]));
    }
  }

  void next() {
    final formation = formationValue;
    final activeFormationRun = formationRunValue;
    if (formation == null || activeFormationRun == null) return;

    final currentIndex = formation.formationRuns.indexOf(activeFormationRun.formationRun);
    if (currentIndex != -1 && currentIndex < formation.formationRuns.length - 1) {
      _rxFormationRun.add(_generateFormationRuneChange(formation.formationRuns[currentIndex + 1]));
    }
  }

  void _changeOpenFullscreenFlag(bool state) {
    _log.fine('$hashCode Changing _openFullscreen to $state');
    _openFullscreen = state;
  }

  void open(BuildContext context) {
    if (_openFullscreen || formationChangedValue) {
      context.router.push(BreakLoadSlipRoute());
      _changeOpenFullscreenFlag(false);
      _rxFormationChanged.add(false);
    } else {
      _detailModalViewModel?.open(BreakLoadSlipModalBuilder(), maximize: false);
    }
  }
}
