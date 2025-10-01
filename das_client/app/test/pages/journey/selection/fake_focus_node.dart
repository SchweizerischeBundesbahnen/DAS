import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class FakeFocusNode extends Fake with ChangeNotifier implements FocusNode {
  bool _hasFocus = false;

  @override
  bool get hasFocus => _hasFocus;

  set hasFocus(bool value) {
    _hasFocus = value;
    notifyListeners();
  }

  // Needed since FocusNode has a special toString method
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => 'FakeFocusNode';
}
