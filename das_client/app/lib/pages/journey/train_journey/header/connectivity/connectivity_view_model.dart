import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/util/time_constants.dart';
import 'package:connectivity_x/component.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectivityDisplayStatus { connected, connectedWifi, disconnected }

class ConnectivityViewModel {
  ConnectivityViewModel({
    required ConnectivityManager connectivityManager,
  }) : _connectivityManager = connectivityManager {
    _init();
  }

  static const timerTickDuration = Duration(seconds: 1);

  final _connectivityLostNotificationDelay = DI.get<TimeConstants>().connectivityLostNotificationDelay;
  final BehaviorSubject<ConnectivityDisplayStatus> _rxModel = BehaviorSubject.seeded(
    ConnectivityDisplayStatus.connected,
  );

  Stream<ConnectivityDisplayStatus> get model => _rxModel.stream.distinct();

  ConnectivityDisplayStatus get modelValue => _rxModel.value;

  final ConnectivityManager _connectivityManager;
  StreamSubscription? _connectivitySubscription;

  Timer? _timer;

  void _init() {
    _connectivitySubscription = _connectivityManager.onConnectivityChanged.listen((connected) {
      if (connected) {
        if (_connectivityManager.isWifiActive()) {
          _rxModel.add(ConnectivityDisplayStatus.connectedWifi);
        } else {
          _rxModel.add(ConnectivityDisplayStatus.connected);
        }
        _timer?.cancel();
      } else {
        _timer?.cancel();
        _timer = Timer.periodic(timerTickDuration, _checkConnectivityState);
      }
    });
  }

  void _checkConnectivityState(Timer t) {
    final now = DateTime.now();
    final lastConnected = _connectivityManager.lastConnected;
    if (lastConnected == null ||
        now.difference(lastConnected) > Duration(seconds: _connectivityLostNotificationDelay)) {
      _rxModel.add(ConnectivityDisplayStatus.disconnected);
      _timer?.cancel();
    }
  }

  void dispose() {
    _rxModel.close();
    _timer?.cancel();
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
