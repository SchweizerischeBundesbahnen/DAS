import 'dart:async';

import 'package:das_client/app/model/ru.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'train_journey_state.dart';

class TrainJourneyCubit extends Cubit<TrainJourneyState> {
  TrainJourneyCubit({
    required SferaService sferaService,
  })  : _sferaService = sferaService,
        super(SelectingTrainJourneyState(date: DateTime.now(), evu: Ru.sbbP));

  final SferaService _sferaService;

  Stream<JourneyProfile?> get journeyStream => _sferaService.journeyStream;

  Stream<List<SegmentProfile>> get segmentStream => _sferaService.segmentStream;

  StreamSubscription? _stateSubscription;

  void loadTrainJourney() async {
    final currentState = state;
    if (currentState is SelectingTrainJourneyState) {
      final date = currentState.date;
      final evu = currentState.evu;
      final trainNumber = currentState.trainNumber;
      if (evu == null || trainNumber == null) {
        Fimber.i('company or trainNumber null');
        return;
      }

      emit(ConnectingState(evu, trainNumber, currentState.date));
      _stateSubscription?.cancel();
      _stateSubscription = _sferaService.stateStream.listen((state) {
        switch (state) {
          case SferaServiceState.connected:
            emit(TrainJourneyLoadedState(evu, trainNumber, date));
            break;
          case SferaServiceState.connecting:
          case SferaServiceState.handshaking:
          case SferaServiceState.loadingJourney:
          case SferaServiceState.loadingSegments:
            emit(ConnectingState(evu, trainNumber, date));
            break;
          case SferaServiceState.disconnected:
          case SferaServiceState.offline:
            emit(SelectingTrainJourneyState(
                evu: evu, trainNumber: trainNumber, date: date, errorCode: _sferaService.lastErrorCode));
            break;
        }
      });
      _sferaService.connect(OtnId.create(evu.companyCode, trainNumber, date));
    }
  }

  void updateTrainNumber(String? trainNumber) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: trainNumber,
          evu: (state as SelectingTrainJourneyState).evu,
          date: (state as SelectingTrainJourneyState).date,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void updateCompany(Ru? evu) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: (state as SelectingTrainJourneyState).trainNumber,
          evu: evu,
          date: (state as SelectingTrainJourneyState).date,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void updateDate(DateTime date) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: (state as SelectingTrainJourneyState).trainNumber,
          evu: (state as SelectingTrainJourneyState).evu,
          date: date,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void reset() {
    if (state is BaseTrainJourneyState) {
      Fimber.i('Reseting TrainJourney cubit in state $state');
      emit(SelectingTrainJourneyState(
          trainNumber: (state as BaseTrainJourneyState).trainNumber,
          date: DateTime.now(),
          evu: (state as BaseTrainJourneyState).evu));
    }
  }
}

extension ContextBlocExtension on BuildContext {
  TrainJourneyCubit get trainJourneyCubit => read<TrainJourneyCubit>();
}
