import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyPositionModel', () {
    test('equality_whenObjectDiffers_thenIsFalse', () {
      // ARRANGE
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel();

      // ACT & EXPECT
      expect(a, isNot(equals(b)));
    });

    test('equality_whenObjectsAreEqual_thenIsTrue', () {
      // ARRANGE
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));

      // ACT & EXPECT
      expect(a, equals(b));
    });

    test('hashCode_whenObjectsAreEqual_thenHashIsEqual', () {
      // ARRANGE
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));

      // ACT & EXPECT
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode_whenObjectsAreDifferent_thenHashIsDifferent', () {
      // ARRANGE
      final a = JourneyPositionModel(currentPosition: Signal(order: 0, kilometre: []));
      final b = JourneyPositionModel();

      // ACT & EXPECT
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
