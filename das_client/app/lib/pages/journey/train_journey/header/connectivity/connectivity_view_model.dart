import 'dart:async';

import 'package:connectivity_x/component.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectivityDisplayStatus {
  connected,
  disconnected,
  disconnectedWifi,
}

class ConnectivityViewModel {
  ConnectivityViewModel({
    required ConnectivityManager connectivityManager,
  }) : _connectivityManager = connectivityManager {
    _init();
  }

  final BehaviorSubject<ConnectivityDisplayStatus> _rxModel = BehaviorSubject.seeded(
    ConnectivityDisplayStatus.connected,
  );

  Stream<ConnectivityDisplayStatus> get model => _rxModel.stream.distinct();

  ConnectivityDisplayStatus get modelValue => _rxModel.value;

  final ConnectivityManager _connectivityManager;
  StreamSubscription? _connectivitySubscription;

  void _init() {
    _connectivitySubscription = _connectivityManager.onConnectivityChanged.listen((connected) {
      if (connected) {
        _rxModel.add(ConnectivityDisplayStatus.connected);
      } else {
        if (_connectivityManager.isWifiActive()) {
          _rxModel.add(ConnectivityDisplayStatus.disconnectedWifi);
        } else {
          _rxModel.add(ConnectivityDisplayStatus.disconnected);
        }
      }
    });
  }

  void dispose() {
    _rxModel.close();
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
