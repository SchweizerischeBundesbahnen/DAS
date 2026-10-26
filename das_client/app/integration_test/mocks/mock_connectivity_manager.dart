import 'package:connectivity_x/component.dart';
import 'package:rxdart/rxdart.dart';

class MockConnectivityManager() implements ConnectivityManager {
  DateTime? lastConnectedTime = DateTime.now();
  final BehaviorSubject<bool> connectivitySubject = BehaviorSubject.seeded(true);
  final BehaviorSubject<bool> wifiActiveSubject = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> networkRoamingSubject = BehaviorSubject.seeded(false);

  @override
  Stream<bool> get isConnected => connectivitySubject.distinct();

  @override
  Stream<bool> get isWifiActive => wifiActiveSubject.distinct();

  @override
  bool get isWifiActiveValue => wifiActiveSubject.value;

  @override
  Stream<bool> get isNetworkRoaming => networkRoamingSubject.distinct();

  @override
  DateTime? get lastConnected => lastConnectedTime;

  @override
  void dispose() {
    connectivitySubject.close();
    wifiActiveSubject.close();
    networkRoamingSubject.close();
  }
}
