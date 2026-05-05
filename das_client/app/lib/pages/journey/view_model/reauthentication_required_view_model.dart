import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:auth/component.dart';
import 'package:connectivity_x/component.dart';
import 'package:logging/logging.dart';

final _log = Logger('ReauthenticationRequiredViewModel');

class ReauthenticationRequiredViewModel {
  ReauthenticationRequiredViewModel({
    required Authenticator authenticator,
    required NotificationPriorityQueueViewModel notificationViewModel,
    required ConnectivityManager connectivityManager,
  }) : _authenticator = authenticator,
       _notificationViewModel = notificationViewModel,
       _connectivityManager = connectivityManager {
    _init();
  }

  final Authenticator _authenticator;
  final NotificationPriorityQueueViewModel _notificationViewModel;
  final ConnectivityManager _connectivityManager;
  StreamSubscription? _authStreamSubscription;
  StreamSubscription? _connectivityStreamSubscription;
  bool? _lastConnectivityState;
  bool? _lastReauthenticationRequiredState;

  void _init() {
    _authStreamSubscription = _authenticator.reauthenticationRequired.listen((state) {
      _lastReauthenticationRequiredState = state;
      _updateNotification();
    });
    _connectivityStreamSubscription = _connectivityManager.onConnectivityChanged.listen((state) {
      _lastConnectivityState = state;
      _updateNotification();
    });
  }

  void _updateNotification() {
    if (_lastReauthenticationRequiredState == true && _lastConnectivityState == true) {
      _notificationViewModel.insert(type: .reauthenticationRequired);
    } else {
      _notificationViewModel.remove(type: .reauthenticationRequired);
    }
  }

  void reauthenticate() async {
    try {
      await _authenticator.login();
    } catch (e) {
      _log.warning('Reauthentication failed: $e');
    }
  }

  void dispose() {
    _authStreamSubscription?.cancel();
    _connectivityStreamSubscription?.cancel();
  }
}
