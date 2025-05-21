import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class UxTestingViewModel {
  UxTestingViewModel({required SferaRemoteRepo sferaService}) : _sferaService = sferaService {
    _init();
  }

  final SferaRemoteRepo _sferaService;

  StreamSubscription? _eventSubscription;
  StreamSubscription? _sferaStateSubscription;

  final _rxUxTestingEvents = BehaviorSubject<UxTestingEvent>();
  final _rxKoaState = BehaviorSubject.seeded(KoaState.waitHide);

  Stream<KoaState> get koaState => _rxKoaState.distinct();

  Stream<UxTestingEvent> get uxTestingEvents => _rxUxTestingEvents.distinct();

  void _init() {
    _eventSubscription = _sferaService.uxTestingEventStream.listen((data) {
      if (data != null) {
        if (data.isKoa) {
          _rxKoaState.add(KoaState.from(data.value));
        }
        _rxUxTestingEvents.add(data);
      }
    });
    _sferaStateSubscription = _sferaService.stateStream.listen((state) {
      if (state == SferaRemoteRepositoryState.disconnected) {
        _rxKoaState.add(KoaState.waitHide);
      }
    });
  }

  void dispose() {
    _rxKoaState.close();
    _eventSubscription?.cancel();
    _sferaStateSubscription?.cancel();
  }
}
