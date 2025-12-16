import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DepartureDispatchNotificationViewModel {
  DepartureDispatchNotificationViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
    required Stream<JourneyPositionModel> journeyPositionStream,
  }) : _sferaRemoteRepo = sferaRemoteRepo {
    _init(journeyPositionStream);
  }

  final SferaRemoteRepo _sferaRemoteRepo;

  final _rxDepartureDispatchNotificationType = BehaviorSubject<DepartureDispatchNotificationType?>.seeded(null);

  StreamSubscription? _streamSubscription;

  final _sound = DI.get<DASSounds>().departureDispatchNotification;

  Stream<DepartureDispatchNotificationType?> get type => _rxDepartureDispatchNotificationType.distinct();

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _rxDepartureDispatchNotificationType.close();
  }

  void _init(Stream<JourneyPositionModel> journeyPositionStream) {
    _streamSubscription = CombineLatestStream.combine2(
      _sferaRemoteRepo.departureDispatchNotificationEventStream,
      journeyPositionStream,
      (a, b) => (a, b),
    ).listen((data) => _handleAndEmitNotification(event: data.$1, journeyPosition: data.$2));
  }

  void _handleAndEmitNotification({
    required DepartureDispatchNotificationEvent? event,
    required JourneyPositionModel journeyPosition,
  }) {
    if (event != null && journeyPosition.lastPosition == null) {
      if (event.type != _rxDepartureDispatchNotificationType.value) {
        _sound.play();
      }
      _rxDepartureDispatchNotificationType.add(event.type);
    } else {
      _rxDepartureDispatchNotificationType.add(null);
    }
  }
}
