import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyPositionModel', () {
    test('equality_whenObjectDiffers_thenIsFalse', () {
      // GIVEN
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel();

      // WHEN & THEN
      expect(a, isNot(equals(b)));
    });

    test('equality_whenObjectsAreEqual_thenIsTrue', () {
      // GIVEN
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));

      // WHEN & THEN
      expect(a, equals(b));
    });

    test('hashCode_whenObjectsAreEqual_thenHashIsEqual', () {
      // GIVEN
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));

      // WHEN & THEN
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode_whenObjectsAreDifferent_thenHashIsDifferent', () {
      // GIVEN
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel();

      // WHEN & THEN
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
