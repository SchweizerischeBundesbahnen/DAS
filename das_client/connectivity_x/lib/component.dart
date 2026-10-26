import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_x/src/connection_check_service.dart';
import 'package:connectivity_x/src/connectivity_manager.dart';
import 'package:connectivity_x/src/connectivity_manager_impl.dart';
import 'package:connectivity_x/src/network_roaming_service.dart';

export 'package:connectivity_x/src/connectivity_manager.dart';

class const ConnectivityComponent._() {
  static ConnectivityManager connectivityManager() {
    return ConnectivityManagerImpl(
      connectivity: Connectivity(),
      networkRoamingService: NetworkRoamingServiceImpl(),
      connectionCheckService: ConnectionCheckServiceImpl(),
    );
  }
}
