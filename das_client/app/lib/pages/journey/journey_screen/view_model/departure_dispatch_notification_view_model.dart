import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DepartureDispatchNotificationViewModel {
  DepartureDispatchNotificationViewModel({
    required SferaRepository sferaRepo,
    required Stream<JourneyPositionModel> journeyPositionStream,
    required NotificationPriorityQueueViewModel notificationVM,
  }) : _sferaRepo = sferaRepo,
       _notificationVM = notificationVM {
    _init(journeyPositionStream);
  }

  final SferaRepository _sferaRepo;

  final NotificationPriorityQueueViewModel _notificationVM;

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
      _sferaRepo.departureDispatchNotificationEventStream,
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
        _notificationVM.insert(type: .departureDispatch, callback: () => _sound.play());
      }
      _rxDepartureDispatchNotificationType.add(event.type);
    } else {
      _notificationVM.remove(type: .departureDispatch);
      _rxDepartureDispatchNotificationType.add(null);
    }
  }
}
