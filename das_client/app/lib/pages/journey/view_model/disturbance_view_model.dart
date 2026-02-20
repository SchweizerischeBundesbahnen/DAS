import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _logger = Logger('DisturbanceViewModel');

class DisturbanceViewModel {
  DisturbanceViewModel({
    required SferaRepository sferaRepo,
    required NotificationPriorityQueueViewModel notificationVM,
  }) : _sferaRepo = sferaRepo,
       _notificationVM = notificationVM {
    _init();
  }

  final SferaRepository _sferaRepo;
  final NotificationPriorityQueueViewModel _notificationVM;
  final _sound = DI.get<DASSounds>().gridOverload;

  final _rxDisturbance = BehaviorSubject<DisturbanceEventType?>.seeded(null);

  Stream<DisturbanceEventType?> get disturbanceStream => _rxDisturbance.stream;

  StreamSubscription? _disturbanceSubscription;

  void _init() {
    _disturbanceSubscription = _sferaRepo.disturbanceEventStream.listen((event) {
      if (event?.type == DisturbanceEventType.start) {
        _logger.fine('Emitting Disturbance Start');
        _notificationVM.insert(type: .disturbance, callback: () => _sound.play());
        _rxDisturbance.add(event!.type);
      } else {
        _logger.fine('Emitting Disturbance Ended');
        _notificationVM.remove(type: .disturbance);
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
