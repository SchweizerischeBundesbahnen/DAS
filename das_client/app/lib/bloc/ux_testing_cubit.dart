import 'dart:async';

import 'package:sfera/component.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'ux_testing_state.dart';

class UxTestingCubit extends Cubit<UxTestingState> {
  UxTestingCubit({required SferaService sferaService})
      : _sferaService = sferaService,
        super(UxTestingInitial());

  final SferaService _sferaService;

  StreamSubscription? _eventSubscription;
  StreamSubscription? _sferaStateSubscription;

  final _koaStateSubject = BehaviorSubject.seeded(KoaState.waitHide);

  Stream<KoaState> get koaStateStream => _koaStateSubject.distinct();

  void initialize() {
    _eventSubscription = _sferaService.uxTestingStream.listen((data) {
      if (data != null) {
        if (data.isKoa) {
          _koaStateSubject.add(
              KoaState.values.firstWhere((element) => element.name == data.value, orElse: () => KoaState.waitHide));
        }

        emit(UxTestingEventReceived(event: data));
      }
    });
    _sferaStateSubscription = _sferaService.stateStream.listen((state) {
      if (state == SferaServiceState.disconnected) {
        _koaStateSubject.add(KoaState.waitHide);
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _sferaStateSubscription?.cancel();
    _sferaStateSubscription = null;

    return super.close();
  }
}
