import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_x/src/connectivity_manager.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('ConnectivityManagerImpl');

class ConnectivityManagerImpl implements ConnectivityManager {
  static const connectivityCheckInterval = Duration(seconds: 15);
  static const lookupHost = 'google.com';
  static ConnectivityManagerImpl? _singleton;

  factory ConnectivityManagerImpl() {
    _singleton ??= ConnectivityManagerImpl._();
    return _singleton!;
  }

  ConnectivityManagerImpl._() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((data) {
      _log.fine('ConnectivityPlus status changed: $data');
      _latestConnectivityResults = data;
      _checkAndUpdateConnectivity();
    });
    _startPeriodicCheck();
  }

  final _connectivity = Connectivity();
  final _connectedSubject = BehaviorSubject<bool>.seeded(false);
  StreamSubscription? _connectivitySubscription;
  List<ConnectivityResult> _latestConnectivityResults = [];
  DateTime? _lastConnectedTime;
  bool _lasteWifiActive = false;
  Timer? _timer;

  void _startPeriodicCheck() {
    _timer = Timer.periodic(connectivityCheckInterval, (_) => _checkAndUpdateConnectivity());
  }

  @override
  bool isConnected() => _connectedSubject.value;

  @override
  bool isWifiActive() => _latestConnectivityResults.contains(ConnectivityResult.wifi);

  @override
  Stream<bool> get onConnectivityChanged => _connectedSubject.stream;

  @override
  DateTime? get lastConnected => _lastConnectedTime;

  void _checkAndUpdateConnectivity() async {
    final isConnected = await _checkConnection();
    if (isConnected) {
      _lastConnectedTime = DateTime.now();
    }
    _emitState(isConnected, isWifiActive());
  }

  void _emitState(bool isConnected, bool wifiActive) {
    if (_connectedSubject.value != isConnected || _lasteWifiActive != wifiActive) {
      _log.info('Internet connectivity changed: $isConnected, isWifi: $wifiActive}');
      _lasteWifiActive = wifiActive;
      _connectedSubject.add(isConnected);
    }
  }

  Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup(lookupHost);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _timer?.cancel();
  }
}
