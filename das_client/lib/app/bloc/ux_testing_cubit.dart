import 'dart:async';

import 'package:das_client/model/journey/ux_testing.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/util/annotations/non_production.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'ux_testing_state.dart';

@nonProduction
class UxTestingCubit extends Cubit<UxTestingState> {
  UxTestingCubit({required SferaService sferaService})
      : _sferaService = sferaService,
        super(UxTestingInitial());

  final SferaService _sferaService;

  StreamSubscription? _eventSubscription;

  void initialize() {
    _eventSubscription = _sferaService.uxTestingStream.listen((data) {
      if (data != null) {
        emit(UxTestingEventReceived(event: data));
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    _eventSubscription = null;

    return super.close();
  }
}
