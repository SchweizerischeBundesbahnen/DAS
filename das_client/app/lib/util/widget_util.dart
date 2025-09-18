import 'package:flutter/material.dart';

class WidgetUtil {
  WidgetUtil._();

  static Offset? findOffsetOfKey(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }
}
