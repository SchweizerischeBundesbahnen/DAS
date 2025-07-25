import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DASRowController extends InheritedWidget {
  DASRowController({required super.child, required this.isAlwaysSticky, super.key}) {
    _rxRowState = BehaviorSubject<DasRowState>.seeded(isAlwaysSticky ? DasRowState.sticky : DasRowState.notSticky);
  }

  late Subject<DasRowState> _rxRowState;

  Stream<DasRowState> get rowState => _rxRowState.stream;

  final bool isAlwaysSticky;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DASRowController? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<DASRowController>();
  }
}

enum DasRowState {
  sticky,
  almostSticky,
  notSticky,
}
