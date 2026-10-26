abstract class const ConnectivityManager._() {
  Stream<bool> get isConnected;

  Stream<bool> get isWifiActive;

  bool get isWifiActiveValue;

  Stream<bool> get isNetworkRoaming;

  DateTime? get lastConnected;

  void dispose();
}
