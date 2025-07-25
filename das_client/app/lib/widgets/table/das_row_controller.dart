import 'package:rxdart/rxdart.dart';

class DASRowController {
  DASRowController({required this.isAlwaysSticky}) {
    _rxRowState = BehaviorSubject<DASRowState>.seeded(isAlwaysSticky ? DASRowState.sticky : DASRowState.notSticky);
  }

  late BehaviorSubject<DASRowState> _rxRowState;

  Stream<DASRowState> get rowState => _rxRowState.stream;

  DASRowState get rowStateValue => _rxRowState.value;

  final bool isAlwaysSticky;
}

enum DASRowState {
  sticky,
  almostSticky,
  notSticky,
}
