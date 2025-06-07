import 'dart:async';

import 'package:app/pages/journey/train_selection/train_journey_selection_model.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class TrainJourneySelectionViewModel {
  static const RailwayUndertaking _initialRailwayUndertaking = RailwayUndertaking.sbbP;

  DateTime Function() get _initialDateTime =>
      () => clock.now();

  final _state = BehaviorSubject<TrainJourneySelectionModel>();

  TrainJourneySelectionViewModel() {
    _emitInitial();
  }

  Stream<TrainJourneySelectionModel> get model => _state.stream;

  TrainJourneySelectionModel get modelValue => _state.value;

  void updateDate(DateTime date) {
    _ifInSelectingEmitWith((model) => model.copyWith(startDate: date));
  }

  void updateTrainNumber(String? trainNumber) {
    _ifInSelectingEmitWith((model) => model.copyWith(operationalTrainNumber: trainNumber));
  }

  void updateRailwayUndertaking(RailwayUndertaking ru) {
    _ifInSelectingEmitWith((model) => model.copyWith(railwayUndertaking: ru));
  }

  void _emitInitial() => _state.add(
    TrainJourneySelectionModel.selecting(
      startDate: _initialDateTime(),
      railwayUndertaking: _initialRailwayUndertaking,
    ),
  );

  void dispose() {
    _state.close();
  }

  void _ifInSelectingEmitWith(Selecting Function(Selecting model) updateFunc) {
    switch (modelValue) {
      case final Selecting model:
        final updatedModel = updateFunc(model);
        final isInputComplete = _validateInput(updatedModel);
        _state.add(updatedModel.copyWith(isInputComplete: isInputComplete));
        break;
      default:
        break;
    }
  }

  _validateInput(Selecting updatedModel) => updatedModel.operationalTrainNumber?.isNotEmpty == true;
}
