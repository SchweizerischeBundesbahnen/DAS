import 'package:flutter/material.dart';

class DeviceScreen {
  const DeviceScreen._();

  /// Returns screen height in logical pixels (dp)
  static double get height => size.height;

  /// Returns screen width in logical pixels (dp)
  static double get width => size.width;

  /// Returns screen dimensions in logical pixels (dp)
  static Size get size {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  static double get systemStatusBarHeight {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.padding.top / view.devicePixelRatio;
  }
}
