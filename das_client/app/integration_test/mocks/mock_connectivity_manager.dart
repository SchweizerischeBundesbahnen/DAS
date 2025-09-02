import 'package:connectivity_x/component.dart';
import 'package:rxdart/rxdart.dart';

class MockConnectivityManager implements ConnectivityManager {
  MockConnectivityManager();

  bool wifiActive = false;
  DateTime lastConnectedTime = DateTime.now();
  BehaviorSubject<bool> connectivitySubject = BehaviorSubject.seeded(true);

  @override
  bool isConnected() {
    return connectivitySubject.value;
  }

  @override
  bool isWifiActive() {
    return wifiActive;
  }

  @override
  DateTime? get lastConnected => lastConnectedTime;

  @override
  Stream<bool> get onConnectivityChanged => connectivitySubject.stream;
}
