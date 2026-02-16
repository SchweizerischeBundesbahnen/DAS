import 'dart:async';

import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneySelectionViewModel');

class JourneySelectionViewModel {
  JourneySelectionViewModel({
    required SferaRepository sferaRepo,
    required Future<void> Function(TrainIdentification) onJourneySelected,
  }) : _sferaRepo = sferaRepo,
       _onJourneySelected = onJourneySelected {
    _emitSelectingWithDefaults();
    _initSferaRepoSubscription();
  }

  final SferaRepository _sferaRepo;

  final Future<void> Function(TrainIdentification) _onJourneySelected;

  StreamSubscription? _sferaRepoSubscription;

  final _state = BehaviorSubject<JourneySelectionModel>();

  Stream<JourneySelectionModel> get model => _state.stream;

  JourneySelectionModel get modelValue => _state.value;

  Future<void> loadJourney() async {
    final currentState = _state.value;
    switch (currentState) {
      case Loading() || Loaded() || Error():
        break;
      case final Selecting state:
        if (!state.isInputComplete) return;
        final trainIdToLoad = _trainIdFrom(state);

        _log.fine('Start loading train journey: $trainIdToLoad');
        await _onJourneySelected(trainIdToLoad);
    }
  }

  void updateDate(DateTime date) {
    _ifInSelectingOrErrorEmitSelectingWith((model) {
      if (!model.availableStartDates.contains(date)) return model;
      return model.copyWith(startDate: date);
    });
  }

  void updateTrainNumber(String? trainNumber) {
    _ifInSelectingOrErrorEmitSelectingWith((model) => model.copyWith(operationalTrainNumber: trainNumber));
  }

  void updateRailwayUndertaking(List<RailwayUndertaking> ru) {
    _ifInSelectingOrErrorEmitSelectingWith((model) => model.copyWith(railwayUndertaking: ru.firstOrNull));
  }

  void dismissSelection() {
    final currentState = _state.value;
    if (currentState is Loading) return;

    _emitSelectingWithDefaults();
  }

  void dispose() {
    _sferaRepoSubscription?.cancel();
    _state.close();
  }

  void _initSferaRepoSubscription() {
    _sferaRepoSubscription = _sferaRepo.stateStream.listen((state) {
      switch (state) {
        case .offlineData:
        case .connected:
          final currentState = _state.value;
          if (currentState is! Loading) return;

          return _state.add(JourneySelectionModel.loaded(trainIdentification: currentState.trainIdentification));
        case .connecting:
          final currentState = _state.value;
          if (currentState is! Selecting) return;

          return _state.add(JourneySelectionModel.loading(trainIdentification: _trainIdFrom(currentState)));
        case .disconnected:
          if (_sferaRepo.lastError == null) return;

          return switch (_state.value) {
            final Loading l => _state.add(
              JourneySelectionModel.error(
                trainIdentification: l.trainIdentification,
                errorCode: .fromSfera(error: _sferaRepo.lastError!),
                availableStartDates: _availableStartDates(),
              ),
            ),
            final Selecting s => _state.add(
              JourneySelectionModel.error(
                trainIdentification: _trainIdFrom(s),
                errorCode: .fromSfera(error: _sferaRepo.lastError!),
                availableStartDates: s.availableStartDates,
              ),
            ),
            _ => null,
          };
      }
    });
  }

  void _emitSelectingWithDefaults() {
    _state.add(
      JourneySelectionModel.selecting(
        startDate: _midnightToday(),
        railwayUndertaking: .sbbP,
        availableStartDates: _availableStartDates(),
      ),
    );
  }

  void _ifInSelectingOrErrorEmitSelectingWith(Selecting Function(Selecting model) updateFunc) {
    switch (modelValue) {
      case final Selecting s:
        final updatedModel = updateFunc(s);
        final isInputComplete = _validateInput(updatedModel);
        _state.add(updatedModel.copyWith(isInputComplete: isInputComplete));
        break;
      case final Error e:
        final updatedModel = updateFunc(
          Selecting(
            startDate: e.startDate,
            railwayUndertaking: e.railwayUndertaking,
            trainNumber: e.operationalTrainNumber,
            availableStartDates: e.availableStartDates,
          ),
        );
        _state.add(updatedModel.copyWith(isInputComplete: _validateInput(updatedModel)));
      default:
        break;
    }
  }

  bool _validateInput(Selecting updatedModel) => updatedModel.trainNumber?.isNotEmpty == true;

  TrainIdentification _trainIdFrom(Selecting selectingState) => TrainIdentification(
    ru: selectingState.railwayUndertaking,
    trainNumber: selectingState.operationalTrainNumber.trim().toUpperCase(),
    date: selectingState.startDate,
  );

  List<DateTime> _availableStartDates() {
    final today = _midnightToday();
    return [
      today.subtract(Duration(days: 1)),
      today,
      if (_isNextDayInFourHours()) today.add(Duration(days: 1)),
    ];
  }

  bool _isNextDayInFourHours() {
    final now = clock.now().toLocal();
    final inFourHours = now.add(Duration(hours: 4));
    return !DateUtils.isSameDay(now, inFourHours);
  }

  DateTime _midnightToday() {
    final now = clock.now().toLocal();
    return DateTime.utc(now.year, now.month, now.day);
  }
}
