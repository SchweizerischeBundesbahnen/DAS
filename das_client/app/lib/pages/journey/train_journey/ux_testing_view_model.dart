import 'dart:async';

import 'package:app/provider/ru_feature_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
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
  final _rxKoaState = BehaviorSubject.seeded(KoaState.waitHide);

  Stream<KoaState> get koaState => _rxKoaState.distinct();

  Stream<UxTestingEvent> get uxTestingEvents => _rxUxTestingEvents.stream;

  Future<bool> get isDepartueProcessFeatureEnabled =>
      _ruFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess);

  void _init() {
    _eventSubscription = _sferaService.uxTestingEventStream.listen((data) async {
      if (data != null) {
        if (data.isKoa) {
          final koaEnabled = await _ruFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.koa);
          if (koaEnabled) {
            _rxKoaState.add(KoaState.from(data.value));
            // TODO: play KOA sound here only for correct event and KOA enabled
          }
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
