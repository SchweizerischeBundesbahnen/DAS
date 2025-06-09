import 'dart:async';

import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySelectionViewModel {
  static const RailwayUndertaking _initialRailwayUndertaking = RailwayUndertaking.sbbP;

  DateTime Function() get _initialDateTime =>
      () => clock.now();

  final _state = BehaviorSubject<JourneySelectionModel>();

  JourneySelectionViewModel() {
    _emitInitial();
  }

  Stream<JourneySelectionModel> get model => _state.stream;

  JourneySelectionModel get modelValue => _state.value;

  void loadTrainJourney() async {
    final currentState = _state.value;
    switch (currentState) {
      case final Selecting sM:
        _state.add(
          Loading(
            trainJourneyIdentification: TrainIdentification(
              date: sM.startDate,
              ru: sM.railwayUndertaking,
              trainNumber: sM.operationalTrainNumber,
            ),
          ),
        );
        await Future.delayed(Duration(seconds: 1));
        _state.add(
          Error(
            errorCode: ErrorCode.connectionFailed,
            trainJourneyIdentification: TrainIdentification(
              date: sM.startDate,
              ru: sM.railwayUndertaking,
              trainNumber: sM.operationalTrainNumber,
            ),
          ),
        );
        // await Future.delayed(Duration(seconds: 1));
        // _state.add(sM);
        break;
      case Loading() || Loaded() || Error():
        break;
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

  void _emitInitial() => _state.add(
    JourneySelectionModel.selecting(
      startDate: _initialDateTime(),
      railwayUndertaking: _initialRailwayUndertaking,
    ),
  );

  void dispose() {
    _state.close();
  }

  void _ifInSelectingOrErrorEmitSelectingWith(Selecting Function(Selecting model) updateFunc) {
    switch (modelValue) {
      case final Selecting sM:
        final updatedModel = updateFunc(sM);
        final isInputComplete = _validateInput(updatedModel);
        _state.add(updatedModel.copyWith(isInputComplete: isInputComplete));
        break;
      case final Error eM:
        final updatedModel = updateFunc(
          Selecting(
            startDate: eM.startDate,
            railwayUndertaking: eM.railwayUndertaking,
            trainNumber: eM.operationalTrainNumber,
          ),
        );
        _state.add(updatedModel.copyWith(isInputComplete: _validateInput(updatedModel)));
      default:
        break;
    }
  }

  _validateInput(Selecting updatedModel) => updatedModel.trainNumber?.isNotEmpty == true;
}
