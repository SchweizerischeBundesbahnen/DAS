import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DisturbanceViewModel {
  DisturbanceViewModel({
    required SferaRepo sferaRepo,
  }) : _sferaRepo = sferaRepo {
    _init();
  }

  final SferaRepo _sferaRepo;
  final _sound = DI.get<DASSounds>().gridOverload;

  final _rxDisturbance = BehaviorSubject<DisturbanceEventType?>.seeded(null);

  Stream<DisturbanceEventType?> get disturbanceStream => _rxDisturbance.stream;

  StreamSubscription? _disturbanceSubscription;

  void _init() {
    _disturbanceSubscription = _sferaRepo.disturbanceEventStream.listen((event) {
      if (event?.type == DisturbanceEventType.start) {
        _sound.play();
        _rxDisturbance.add(event!.type);
      } else {
        _rxDisturbance.add(null);
      }
    });
  }

  void dispose() {
    _disturbanceSubscription?.cancel();
    _disturbanceSubscription = null;
    _rxDisturbance.close();
  }
}
