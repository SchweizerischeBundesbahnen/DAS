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
    _emitInitial();
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

        final trainIdentification = TrainIdentification(
          ru: s.railwayUndertaking,
          trainNumber: s.operationalTrainNumber.trim(),
          date: s.startDate,
        );
        _state.add(JourneySelectionModel.loading(trainIdentification: trainIdentification));

        _sferaRemoteRepo.connect(
          OtnId(
            company: trainIdentification.ru.companyCode,
            operationalTrainNumber: trainIdentification.trainNumber,
            startDate: trainIdentification.date,
          ),
        );
    }
  }

  void _initSferaRepoSubscription() {
    _sferaRemoteRepoSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          switch (_state.value) {
            case final Loading lM:
              _state.add(JourneySelectionModel.loaded(trainIdentification: lM.trainIdentification));
              _onJourneySelected(lM.trainIdentification);
              break;
            case final Selecting _ || final Error _ || final Loaded _:
              break;
          }
          break;
        case SferaRemoteRepositoryState.connecting:
        case SferaRemoteRepositoryState.handshaking:
        case SferaRemoteRepositoryState.loadingJourney:
        case SferaRemoteRepositoryState.loadingAdditionalData:
          break;
        case SferaRemoteRepositoryState.disconnected:
        case SferaRemoteRepositoryState.offline:
          if (_sferaRemoteRepo.lastError != null) {
            switch (_state.value) {
              case final Loading l:
                _state.add(
                  JourneySelectionModel.error(
                    trainIdentification: l.trainIdentification,
                    errorCode: ErrorCode.fromSfera(_sferaRemoteRepo.lastError!),
                  ),
                );
                break;
              case final Selecting s:
                _state.add(
                  JourneySelectionModel.error(
                    trainIdentification: TrainIdentification(
                      ru: s.railwayUndertaking,
                      trainNumber: s.operationalTrainNumber,
                      date: s.startDate,
                    ),
                    errorCode: ErrorCode.fromSfera(_sferaRemoteRepo.lastError!),
                  ),
                );
                break;
              case final Loaded _ || final Error _:
                break;
            }
          }
          break;
      }
    });
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
      startDate: clock.now(),
      railwayUndertaking: RailwayUndertaking.sbbP,
    ),
  );

  void dispose() {
    _sferaRemoteRepoSubscription?.cancel();
    _state.close();
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
          ),
        );
        _state.add(updatedModel.copyWith(isInputComplete: _validateInput(updatedModel)));
      default:
        break;
    }
  }

  _validateInput(Selecting updatedModel) => updatedModel.trainNumber?.isNotEmpty == true;
}
