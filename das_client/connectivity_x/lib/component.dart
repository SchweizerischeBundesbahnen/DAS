import 'package:connectivity_x/src/connectivity_manager.dart';
import 'package:connectivity_x/src/connectivity_manager_impl.dart';

export 'package:connectivity_x/src/connectivity_manager.dart';

class ConnectivityComponent {
  const ConnectivityComponent._();

  static ConnectivityManager connectivityManager() {
    return ConnectivityManagerImpl();
  }
}
