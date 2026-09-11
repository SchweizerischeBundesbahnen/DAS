import 'package:rxdart/rxdart.dart';

// TODO: remove this with https://github.com/SchweizerischeBundesbahnen/DAS/issues/2734
// Hint: start by removing complete dir
class ValidationModeViewModel {
  final BehaviorSubject<bool> _rxValidationMode = BehaviorSubject.seeded(false);

  Stream<bool> get validationMode => _rxValidationMode.stream.distinct();

  bool get validationModeValue => _rxValidationMode.value;

  void toggleValidationMode() {
    _rxValidationMode.add(!_rxValidationMode.value);
  }

  void dispose() {
    _rxValidationMode.close();
  }
}
