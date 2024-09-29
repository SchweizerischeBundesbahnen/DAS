import 'dart:async';

import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/service/sfera/sfera_service.dart';
import 'package:das_client/service/sfera/sfera_service_state.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fahrbild_state.dart';

class FahrbildCubit extends Cubit<FahrbildState> {
  FahrbildCubit({
    required SferaService sferaService,
  })  : _sferaService = sferaService,
        super(SelectingFahrbildState());

  final SferaService _sferaService;

  Stream<JourneyProfile?> get journeyStream => _sferaService.journeyStream;

  Stream<List<SegmentProfile>> get segmentStream => _sferaService.segmentStream;

  StreamSubscription? _stateSubscription;

  void loadFahrbild() async {
    final currentState = state;
    if (currentState is SelectingFahrbildState) {
      final now = DateTime.now();
      final company = currentState.company;
      final trainNumber = currentState.trainNumber;
      if (company == null || trainNumber == null) {
        Fimber.i("company or trainNumber null");
        return;
      }

      emit(ConnectingState(company, trainNumber, now));
      _stateSubscription?.cancel();
      _stateSubscription = _sferaService.stateStream.listen((state) {
        switch (state) {
          case SferaServiceState.connected:
            emit(FahrbildLoadedState(company, trainNumber, now));
            break;
          case SferaServiceState.connecting:
          case SferaServiceState.handshaking:
          case SferaServiceState.loadingJourney:
          case SferaServiceState.loadingSegments:
            emit(ConnectingState(company, trainNumber, now));
            break;
          case SferaServiceState.disconnected:
          case SferaServiceState.offline:
            emit(SelectingFahrbildState(
                company: company, trainNumber: trainNumber, errorCode: _sferaService.lastErrorCode));
            break;
        }
      });
      _sferaService.connect(OtnId.create(company, trainNumber, now));
    }
  }

  void updateTrainNumber(String? trainNumber) {
    if (state is SelectingFahrbildState) {
      emit(SelectingFahrbildState(
          trainNumber: trainNumber,
          company: (state as SelectingFahrbildState).company,
          errorCode: (state as SelectingFahrbildState).errorCode));
    }
  }

  void updateCompany(String? company) {
    if (state is SelectingFahrbildState) {
      emit(SelectingFahrbildState(
          trainNumber: (state as SelectingFahrbildState).trainNumber,
          company: company,
          errorCode: (state as SelectingFahrbildState).errorCode));
    }
  }

  void reset() {
    if (state is BaseFahrbildState) {
      Fimber.i("Reseting fahrbild cubit in state $state");
      emit(SelectingFahrbildState(
          trainNumber: (state as BaseFahrbildState).trainNumber, company: (state as BaseFahrbildState).company));
    }
  }
}

extension ContextBlocExtension on BuildContext {
  FahrbildCubit get fahrbildCubit => read<FahrbildCubit>();
}
