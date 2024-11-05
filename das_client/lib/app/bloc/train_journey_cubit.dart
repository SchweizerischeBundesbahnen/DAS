import 'dart:async';

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
        super(SelectingTrainJourneyState());

  final SferaService _sferaService;

  Stream<JourneyProfile?> get journeyStream => _sferaService.journeyStream;

  Stream<List<SegmentProfile>> get segmentStream => _sferaService.segmentStream;

  StreamSubscription? _stateSubscription;

  void loadTrainJourney() async {
    final currentState = state;
    if (currentState is SelectingTrainJourneyState) {
      final now = DateTime.now();
      final company = currentState.company;
      final trainNumber = currentState.trainNumber;
      if (company == null || trainNumber == null) {
        Fimber.i('company or trainNumber null');
        return;
      }

      emit(ConnectingState(company, trainNumber, now));
      _stateSubscription?.cancel();
      _stateSubscription = _sferaService.stateStream.listen((state) {
        switch (state) {
          case SferaServiceState.connected:
            emit(TrainJourneyLoadedState(company, trainNumber, now));
            break;
          case SferaServiceState.connecting:
          case SferaServiceState.handshaking:
          case SferaServiceState.loadingJourney:
          case SferaServiceState.loadingSegments:
            emit(ConnectingState(company, trainNumber, now));
            break;
          case SferaServiceState.disconnected:
          case SferaServiceState.offline:
            emit(SelectingTrainJourneyState(
                company: company, trainNumber: trainNumber, errorCode: _sferaService.lastErrorCode));
            break;
        }
      });
      _sferaService.connect(OtnId.create(company, trainNumber, now));
    }
  }

  void updateTrainNumber(String? trainNumber) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: trainNumber,
          company: (state as SelectingTrainJourneyState).company,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void updateCompany(String? company) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: (state as SelectingTrainJourneyState).trainNumber,
          company: company,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void reset() {
    if (state is BaseTrainJourneyState) {
      Fimber.i('Reseting TrainJourney cubit in state $state');
      emit(SelectingTrainJourneyState(
          trainNumber: (state as BaseTrainJourneyState).trainNumber,
          company: (state as BaseTrainJourneyState).company));
    }
  }
}

extension ContextBlocExtension on BuildContext {
  TrainJourneyCubit get trainJourneyCubit => read<TrainJourneyCubit>();
}
