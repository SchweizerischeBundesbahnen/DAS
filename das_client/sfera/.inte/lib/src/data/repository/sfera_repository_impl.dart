import 'package:rxdart/rxdart.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/ux_testing_nse_dto.dart';
import 'package:sfera/src/data/repository/sfera_repository_flavor.dart';
import 'package:sfera/src/data/repository/sfera_repository_impl_base.dart';
import 'package:sfera/src/model/journey/ux_testing_event.dart';

/// adds UX-testing-event behavior on top of [SferaRepoImplBase] WITHOUT duplicating
mixin UxTestingMixin on SferaRepoImplBase implements SferaFlavorRepository {
  final _rxUxTestingEvent = BehaviorSubject<UxTestingEvent?>.seeded(null);

  @override
  Stream<UxTestingEvent?> get uxTestingEventStream => _rxUxTestingEvent.stream;

  @override
  void onFlavorNetworkSpecificEvent(NetworkSpecificEventDto data) {
    if (data is! UxTestingNseDto) return;

    if (data.koa != null) {
      _rxUxTestingEvent.add(UxTestingEvent(name: data.koa!.name, value: data.koa!.nspValue));
    }
    if (data.warn != null) {
      _rxUxTestingEvent.add(UxTestingEvent(name: data.warn!.name, value: data.warn!.nspValue));
    }
    if (data.connectivity != null) {
      _rxUxTestingEvent.add(UxTestingEvent(name: data.connectivity!.name, value: data.connectivity!.nspValue));
    }
    if (data.formation != null) {
      _rxUxTestingEvent.add(UxTestingEvent(name: data.formation!.name, value: ''));
    }
  }

  @override
  void resetFlavorStreams() => _rxUxTestingEvent.add(null);

  @override
  void disposeFlavor() => _rxUxTestingEvent.close();
}

class SferaRepoImpl = SferaRepoImplBase with UxTestingMixin;
