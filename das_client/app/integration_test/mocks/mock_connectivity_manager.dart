import 'package:connectivity_x/component.dart';
import 'package:rxdart/rxdart.dart';

class MockConnectivityManager() implements ConnectivityManager {
  bool wifiActive = false;
  DateTime lastConnectedTime = DateTime.now();
  BehaviorSubject<bool> connectivitySubject = BehaviorSubject.seeded(true);

  @override
  bool isConnected() => connectivitySubject.value;

  @override
  bool isWifiActive() => wifiActive;

  @override
  DateTime? get lastConnected => lastConnectedTime;

  @override
  Stream<bool> get onConnectivityChanged => connectivitySubject.stream;
}
