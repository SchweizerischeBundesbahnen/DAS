import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('Unittest Speed', () {
    test(
      'isValid_whenSingleSpeed_thenReturnsTrue',
      () => expect(Speed.isValid('80'), isTrue),
    );

    test(
      'isValid_whenSingleSpeedWithDecoration_thenReturnsTrue',
      () => expect(Speed.isValid('[90]') && Speed.isValid('{100}'), isTrue),
    );

    test(
      'isValid_whenGraduatedSpeed_thenReturnsTrue',
      () => expect(Speed.isValid('80-70-60'), isTrue),
    );

    test(
      'isValid_whenIncomingOutgoingSpeed_thenReturnsTrue',
      () => expect(Speed.isValid('80/60'), isTrue),
    );

    test(
      'isValid_whenComplexCombination_thenReturnsTrue',
      () => expect(Speed.isValid('80-[70]/60-{50}-XX'), isTrue),
    );

    test('isValid_whenInvalidFormat_thenReturnsFalse', () {
      // ARRANGE
      const inputs = ['5a0', '', '(50)', '80/70/60', '80//60'];

      // ACT & EXPECT
      for (final input in inputs) {
        expect(Speed.isValid(input), isFalse, reason: 'Should be invalid: $input');
      }
    });

    test('parse_whenSingleSpeedFormat_thenReturnsSingleSpeedType', () {
      // ARRANGE
      const inputs = ['80', '[90]', '{100}', 'XX', '[XX]', '{XX}'];

      // ACT & EXPECT
      for (final input in inputs) {
        expect(Speed.parse(input), isA<SingleSpeed>());
      }
    });

    test('parse_whenGraduatedSpeedFormat_thenReturnsGraduatedSpeedType', () {
      // ARRANGE
      const inputs = ['80-70', '80-[70]-60', '{80}-XX-40'];

      // ACT & EXPECT
      for (final input in inputs) {
        expect(Speed.parse(input), isA<GraduatedSpeed>());
      }
    });

    test('parse_whenIncomingOutgoingFormat_thenReturnsIncomingOutgoingSpeedType', () {
      // ARRANGE
      const inputs = ['80/70', '80-70/60', '80/60-50'];

      // ACT & EXPECT
      for (final input in inputs) {
        expect(Speed.parse(input), isA<IncomingOutgoingSpeed>());
      }
    });
  });
}
