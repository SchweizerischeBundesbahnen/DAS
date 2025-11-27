import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class UxTestingViewModel {
  UxTestingViewModel({required SferaRemoteRepo sferaService, required RuFeatureProvider ruFeatureProvider})
    : _sferaService = sferaService,
      _ruFeatureProvider = ruFeatureProvider {
    _init();
  }

  final SferaRemoteRepo _sferaService;
  final RuFeatureProvider _ruFeatureProvider;

  StreamSubscription? _eventSubscription;
  StreamSubscription? _sferaStateSubscription;

  final _rxUxTestingEvents = BehaviorSubject<UxTestingEvent>();
  final _rxKoaState = BehaviorSubject<KoaState>.seeded(.waitHide);

  Stream<KoaState> get koaState => _rxKoaState.distinct();

  Stream<UxTestingEvent> get uxTestingEvents => _rxUxTestingEvents.stream;

  Future<bool> get isDepartueProcessFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.departureProcess);

  void _init() {
    _eventSubscription = _sferaService.uxTestingEventStream.listen((data) async {
      if (data != null) {
        if (data.isKoa) {
          final koaEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.koa);
          if (koaEnabled) {
            final koaState = KoaState.from(data.value);
            _rxKoaState.add(koaState);
            if (koaState == .waitCancelled) {
              DI.get<DASSounds>().koa.play();
            }
          }
        }
        _rxUxTestingEvents.add(data);
      }
    });
    _sferaStateSubscription = _sferaService.stateStream.listen((state) {
      if (state == .disconnected) {
        _rxKoaState.add(.waitHide);
      }
    });
  }

  void dispose() {
    _rxKoaState.close();
    _eventSubscription?.cancel();
    _sferaStateSubscription?.cancel();
  }
}
