import 'package:app/util/screen_dimensions.dart';
import 'package:flutter/material.dart';

class DeviceScreen {
  DeviceScreen._();

  static double get systemStatusBarHeight {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.padding.top / view.devicePixelRatio;
  }

  static Size get size => ScreenDimensions.screenSize;
}
