import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _log = Logger('NetworkRoamingServiceImpl');

abstract class const NetworkRoamingService._() {
  Future<bool> isNetworkRoaming();
}

class const NetworkRoamingServiceImpl() implements NetworkRoamingService {
  static const _channelName = 'connectivity_manager';
  static const _methodName = 'isNetworkRoaming';

  final MethodChannel _platform = const MethodChannel(_channelName);

  @override
  Future<bool> isNetworkRoaming() async {
    // iOS does not provide a public API to request roaming state.
    if (!Platform.isAndroid) return false;

    try {
      return await _platform.invokeMethod<bool>(_methodName) ?? false;
    } catch (error, stackTrace) {
      _log.warning('Failed to read network roaming state from native layer', error, stackTrace);
      return false;
    }
  }
}
