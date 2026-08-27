abstract class const ConnectivityManager._() {
  Stream<bool> get onConnectivityChanged;

  bool isConnected();

  bool isWifiActive();

  DateTime? get lastConnected;
}
