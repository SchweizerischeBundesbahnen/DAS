import 'package:app/pages/journey/journey_validation/validation_mode_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ValidationModeViewModel testee;
  late FakeAsync testAsync;
  final List<bool> validationModeRegister = [];

  setUp(() {
    testAsync = FakeAsync().run((testAsync) {
      testee = ValidationModeViewModel();
      testee.validationMode.listen(validationModeRegister.add);
      return testAsync;
    });
    testAsync.flushMicrotasks();
    validationModeRegister.clear();
  });

  tearDown(() {
    validationModeRegister.clear();
    testee.dispose();
  });

  test('initialState_whenValidationModeNeverToggled_thenIsFalse', () {
    expect(testee.validationModeValue, isFalse);
    expect(validationModeRegister, isEmpty);
  });

  test('toggleValidationMode_whenModeToggled_thenIsTrue', () {
    // ACT
    testAsync.run((_) {
      testee.toggleValidationMode();
    });
    testAsync.flushMicrotasks();

    // EXPECT
    expect(testee.validationModeValue, isTrue);
    expect(validationModeRegister, hasLength(1));
  });

  test('toggleValidationMode_whenModeToggledTwice_thenIsFalse', () {
    // ACT
    testAsync.run((_) {
      testee.toggleValidationMode();
      testee.toggleValidationMode();
    });
    testAsync.flushMicrotasks();

    // EXPECT
    expect(testee.validationModeValue, isFalse);
    expect(validationModeRegister, hasLength(2));
  });
}
