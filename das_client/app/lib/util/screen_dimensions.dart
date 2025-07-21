import 'package:flutter/material.dart';

class ScreenDimensions {
  ScreenDimensions._();

  /// Returns screen height in logical pixels (dp)
  static double get height => screenSize.height;

  /// Returns screen width in logical pixels (dp)
  static double get width => screenSize.width;

  /// Returns screen dimensions in logical pixels (dp)
  static Size get screenSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }
}
