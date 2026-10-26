import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_x/src/connection_check_service.dart';
import 'package:connectivity_x/src/connectivity_manager.dart';
import 'package:connectivity_x/src/network_roaming_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('ConnectivityManagerImpl');

class ConnectivityManagerImpl({
  required final Connectivity _connectivity,
  required final NetworkRoamingService _networkRoamingService,
  required final ConnectionCheckService _connectionCheckService,
}) implements ConnectivityManager {
  static const connectivityCheckInterval = Duration(seconds: 15);

  this {
    _init();
  }

  final _rxIsConnected = BehaviorSubject<bool>.seeded(false);
  final _rxIsWifiActive = BehaviorSubject<bool>.seeded(false);
  final _rxIsNetworkRoaming = BehaviorSubject<bool>.seeded(false);
  StreamSubscription? _connectivitySubscription;

  List<ConnectivityResult> _latestConnectivityResults = [];
  DateTime? _lastConnectedTime;
  Timer? _timer;

  @override
  bool get isWifiActiveValue => _rxIsWifiActive.value;

  @override
  Stream<bool> get isWifiActive => _rxIsWifiActive.distinct();

  @override
  Stream<bool> get isNetworkRoaming => _rxIsNetworkRoaming.distinct();

  @override
  Stream<bool> get isConnected => _rxIsConnected.distinct();

  @override
  DateTime? get lastConnected => _lastConnectedTime;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _timer?.cancel();
  }

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((data) {
      _log.fine('ConnectivityPlus status changed: $data');
      _latestConnectivityResults = data;

      _checkAndUpdateConnectivity();
    });
    _startPeriodicCheck();
  }

  void _checkAndUpdateConnectivity() async {
    final isWifiActive = _latestConnectivityResults.contains(ConnectivityResult.wifi);
    final isNetworkRoaming = await _networkRoamingService.isNetworkRoaming();
    final isConnected = await _connectionCheckService.hasInternetConnection();
    if (isConnected) {
      _lastConnectedTime = DateTime.now();
    }
    _emitState(isConnected: isConnected, isWifiActive: isWifiActive, isNetworkRoaming: isNetworkRoaming);
  }

  void _emitState({required bool isConnected, required bool isWifiActive, required bool isNetworkRoaming}) {
    if (_rxIsConnected.value != isConnected ||
        _rxIsWifiActive.value != isWifiActive ||
        _rxIsNetworkRoaming.value != isNetworkRoaming) {
      _log.info('Internet connectivity changed: $isConnected, isWifi: $isWifiActive, isRoaming: $isNetworkRoaming');
      _rxIsWifiActive.add(isWifiActive);
      _rxIsNetworkRoaming.add(isNetworkRoaming);
      _rxIsConnected.add(isConnected);
    }
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(connectivityCheckInterval, (_) => _checkAndUpdateConnectivity());
  }
}
