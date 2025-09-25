import 'dart:async';

import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySelectionViewModel {
  JourneySelectionViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
    required Future<void> Function(TrainIdentification) onJourneySelected,
  }) : _sferaRemoteRepo = sferaRemoteRepo,
       _onJourneySelected = onJourneySelected {
    _emitSelectingWithDefaults();
    _initSferaRepoSubscription();
  }

  final SferaRemoteRepo _sferaRemoteRepo;

  final Future<void> Function(TrainIdentification) _onJourneySelected;

  StreamSubscription? _sferaRemoteRepoSubscription;

  final _state = BehaviorSubject<JourneySelectionModel>();

  Stream<JourneySelectionModel> get model => _state.stream;

  JourneySelectionModel get modelValue => _state.value;

  Future<void> loadTrainJourney() async {
    final currentState = _state.value;
    switch (currentState) {
      case Loading() || Loaded() || Error():
        break;
      case final Selecting s:
        if (!s.isInputComplete) return;

        await _onJourneySelected(_trainIdFrom(s));
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

  void updateRailwayUndertaking(RailwayUndertaking ru) {
    _ifInSelectingOrErrorEmitSelectingWith((model) => model.copyWith(railwayUndertaking: ru));
  }

  void dismissSelection() {
    final currentState = _state.value;
    if (currentState is Loading) return;

    _emitSelectingWithDefaults();
  }

  void dispose() {
    _sferaRemoteRepoSubscription?.cancel();
    _state.close();
  }

  void _initSferaRepoSubscription() {
    _sferaRemoteRepoSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          final currentState = _state.value;
          if (currentState is! Loading) return;

          return _state.add(JourneySelectionModel.loaded(trainIdentification: currentState.trainIdentification));
        case SferaRemoteRepositoryState.connecting:
          final currentState = _state.value;
          if (currentState is! Selecting) return;

          return _state.add(JourneySelectionModel.loading(trainIdentification: _trainIdFrom(currentState)));
        case SferaRemoteRepositoryState.disconnected:
          if (_sferaRemoteRepo.lastError == null) return;

          return switch (_state.value) {
            final Loading l => _state.add(
              JourneySelectionModel.error(
                trainIdentification: l.trainIdentification,
                errorCode: ErrorCode.fromSfera(_sferaRemoteRepo.lastError!),
                availableStartDates: _availableStartDates(),
              ),
            ),
            final Selecting s => _state.add(
              JourneySelectionModel.error(
                trainIdentification: _trainIdFrom(s),
                errorCode: ErrorCode.fromSfera(_sferaRemoteRepo.lastError!),
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
        railwayUndertaking: RailwayUndertaking.sbbP,
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
