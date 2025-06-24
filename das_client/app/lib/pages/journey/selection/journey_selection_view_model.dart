import 'dart:async';

import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySelectionViewModel {
  JourneySelectionViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
    required Function(TrainIdentification) onJourneySelected,
  }) : _sferaRemoteRepo = sferaRemoteRepo,
       _onJourneySelected = onJourneySelected {
    _emitSelectingWithDefaults();
    _initSferaRepoSubscription();
  }

  final SferaRemoteRepo _sferaRemoteRepo;

  final Function(TrainIdentification) _onJourneySelected;

  StreamSubscription? _sferaRemoteRepoSubscription;

  final _state = BehaviorSubject<JourneySelectionModel>();

  Stream<JourneySelectionModel> get model => _state.stream;

  JourneySelectionModel get modelValue => _state.value;

  void loadTrainJourney() async {
    final currentState = _state.value;
    switch (currentState) {
      case Loading() || Loaded() || Error():
        break;
      case final Selecting s:
        if (!s.isInputComplete) return;

        _onJourneySelected(_trainIdFrom(s));
    }
  }

  void updateDate(DateTime date) {
    _ifInSelectingOrErrorEmitSelectingWith((model) => model.copyWith(startDate: date));
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
              ),
            ),
            final Selecting s => _state.add(
              JourneySelectionModel.error(
                trainIdentification: _trainIdFrom(s),
                errorCode: ErrorCode.fromSfera(_sferaRemoteRepo.lastError!),
              ),
            ),
            _ => null,
          };
      }
    });
  }

  void _emitSelectingWithDefaults() => _state.add(
    JourneySelectionModel.selecting(
      startDate: clock.now(),
      railwayUndertaking: RailwayUndertaking.sbbP,
    ),
  );

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
    trainNumber: selectingState.operationalTrainNumber.trim(),
    date: selectingState.startDate,
  );
}
