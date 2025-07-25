import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DASRowController extends InheritedWidget {
  DASRowController({required super.child, required this.isAlwaysSticky, super.key}) {
    _rxRowState = BehaviorSubject<DASRowState>.seeded(isAlwaysSticky ? DASRowState.sticky : DASRowState.notSticky);
  }

  late BehaviorSubject<DASRowState> _rxRowState;

  Stream<DASRowState> get rowState => _rxRowState.stream;

  DASRowState get rowStateValue => _rxRowState.value;

  final bool isAlwaysSticky;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DASRowController? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<DASRowController>();
  }
}

enum DASRowState {
  sticky,
  almostSticky,
  notSticky,
}
