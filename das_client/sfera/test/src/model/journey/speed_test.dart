import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('Unittest Speed', () {
    test(
      'isValid_whenSingleSpeed_thenReturnsTrue',
      () => expect(Speed.isValid('80'), isTrue),
    );

    test(
      'isValid_whenSingleSpeedMinusOneThousand_thenReturnsTrue',
      () => expect(Speed.isValid('-1000'), isTrue),
    );

    test(
      'isValid_whenSingleSpeedWithWhitespace_thenReturnsTrue',
      () => expect(Speed.isValid(' 80 '), isTrue),
    );

    test(
      'isValid_whenSingleSpeedWithDecoration_thenReturnsTrue',
      () => expect(Speed.isValid('[90]') && Speed.isValid('{100}'), isTrue),
    );

    test(
      'isValid_whenSingleSpeedWithDecorationAndWhitespaces_thenReturnsTrue',
      () => expect(Speed.isValid('[90 ]') && Speed.isValid('{ 100}'), isTrue),
    );

    test(
      'isValid_whenGraduatedSpeed_thenReturnsTrue',
      () => expect(Speed.isValid('80-70-60'), isTrue),
    );

    test(
      'isValid_whenGraduatedSpeedWithWhitespaces_thenReturnsTrue',
      () => expect(Speed.isValid('80- 70 -60'), isTrue),
    );

    test(
      'isValid_whenIncomingOutgoingSpeed_thenReturnsTrue',
      () => expect(Speed.isValid('80/60'), isTrue),
    );

    test(
      'isValid_whenIncomingOutgoingSpeedWithWhitespaces_thenReturnsTrue',
      () => expect(Speed.isValid('80 / 60'), isTrue),
    );

    test(
      'isValid_whenComplexCombination_thenReturnsTrue',
      () => expect(Speed.isValid('80-[70]/60-{50}-XX'), isTrue),
    );

    test('isValid_whenInvalidFormat_thenReturnsFalse', () {
      // GIVEN
      const inputs = ['5a0', '', '(50)', '80/70/60', '80//60', '80 // 60'];

      // WHEN & THEN
      for (final input in inputs) {
        expect(Speed.isValid(input), isFalse, reason: 'Should be invalid: $input');
      }
    });

    test(
      'isIllegal_whenSingleSpeedMinusOneThousand_thenReturnsTrue',
      () => expect(Speed.parse('-1000').isIllegal, isTrue),
    );

    test('parse_whenSingleSpeedFormat_thenReturnsSingleSpeedType', () {
      // GIVEN
      const inputs = ['80', '[90]', '{100}', 'XX', '[XX]', '{XX}', '{XX }'];

      // WHEN & THEN
      for (final input in inputs) {
        expect(Speed.parse(input), isA<SingleSpeed>());
      }
    });

    test('parse_whenGraduatedSpeedFormat_thenReturnsGraduatedSpeedType', () {
      // GIVEN
      const inputs = ['80-70', '80-[70]-60', '{80}-XX-40', '{80}- XX- 40'];

      // WHEN & THEN
      for (final input in inputs) {
        expect(Speed.parse(input), isA<GraduatedSpeed>());
      }
    });

    test('parse_whenIncomingOutgoingFormat_thenReturnsIncomingOutgoingSpeedType', () {
      // GIVEN
      const inputs = ['80/70', '80-70/60', '80/60-50', '80 /60- 50'];

      // WHEN & THEN
      for (final input in inputs) {
        expect(Speed.parse(input), isA<IncomingOutgoingSpeed>());
      }
    });
  });
}
