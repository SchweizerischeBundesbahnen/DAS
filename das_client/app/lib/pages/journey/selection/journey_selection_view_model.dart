import 'dart:async';

import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneySelectionViewModel {
  JourneySelectionViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
  }) : _sferaRemoteRepo = sferaRemoteRepo {
    _emitInitial();
  }

  final SferaRemoteRepo _sferaRemoteRepo;

  StreamSubscription? _stateSubscription;

  static const RailwayUndertaking _initialRailwayUndertaking = RailwayUndertaking.sbbP;

  DateTime Function() get _initialDateTime =>
      () => clock.now();

  final _state = BehaviorSubject<JourneySelectionModel>();

  Stream<JourneySelectionModel> get model => _state.stream;

  JourneySelectionModel get modelValue => _state.value;

  void loadTrainJourney() async {
    final currentState = _state.value;
    switch (currentState) {
      case Loading() || Loaded() || Error():
        break;
      case final Selecting sM:
        if (!sM.isInputComplete) return;

        final trainIdentification = TrainIdentification(
          ru: sM.railwayUndertaking,
          trainNumber: sM.operationalTrainNumber.trim(),
          date: sM.startDate,
        );
        _state.add(JourneySelectionModel.loading(trainJourneyIdentification: trainIdentification));

        _stateSubscription?.cancel();
        _stateSubscription = _sferaRemoteRepo.stateStream.listen((state) {
          switch (state) {
            case SferaRemoteRepositoryState.connected:
              _state.add(JourneySelectionModel.loaded(trainJourneyIdentification: trainIdentification));
              break;
            case SferaRemoteRepositoryState.connecting:
            case SferaRemoteRepositoryState.handshaking:
            case SferaRemoteRepositoryState.loadingJourney:
            case SferaRemoteRepositoryState.loadingAdditionalData:
              break;
            case SferaRemoteRepositoryState.disconnected:
            case SferaRemoteRepositoryState.offline:
              if (_sferaRemoteRepo.lastError != null) {
                _state.add(
                  JourneySelectionModel.error(
                    trainJourneyIdentification: trainIdentification,
                    errorCode: ErrorCode.fromSfera(_sferaRemoteRepo.lastError!),
                  ),
                );
              }
              break;
          }
        });

        _sferaRemoteRepo.connect(
          OtnId(
            company: trainIdentification.ru.companyCode,
            operationalTrainNumber: trainIdentification.trainNumber,
            startDate: trainIdentification.date,
          ),
        );
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
    _stateSubscription?.cancel();
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
