import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/util/time_constants.dart';
import 'package:rxdart/rxdart.dart';

class DecisiveGradientViewModel {
  DecisiveGradientViewModel() : _resetToKmAfterSeconds = DI.get<TimeConstants>().kmDecisiveGradientResetSeconds;

  final int _resetToKmAfterSeconds;

  Stream<bool> get showDecisiveGradient => _rxShowDecisiveGradient.distinct();

  bool get showDecisiveGradientValue => _rxShowDecisiveGradient.value;

  final _rxShowDecisiveGradient = BehaviorSubject<bool>.seeded(false);
  Timer? _showDecisiveGradientTimer;

  void toggleShowDecisiveGradient() {
    if (!showDecisiveGradientValue) {
      _rxShowDecisiveGradient.add(true);
      _showDecisiveGradientTimer = Timer(Duration(seconds: _resetToKmAfterSeconds), () {
        if (_rxShowDecisiveGradient.value) _rxShowDecisiveGradient.add(false);
      });
    } else {
      _rxShowDecisiveGradient.add(false);
      _showDecisiveGradientTimer?.cancel();
    }
  }

  void dispose() {
    _rxShowDecisiveGradient.close();
    _showDecisiveGradientTimer?.cancel();
  }
}
