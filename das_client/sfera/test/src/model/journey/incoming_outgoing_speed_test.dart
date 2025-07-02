import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/speed.dart';

void main() {
  group('UnitTest IncomingOutgoingSpeed', () {
    test('parse_whenTwoPlainSpeed_thenCreatesCorrectIncomingAndOutgoing', () {
      _expectIncomingOutgoingSpeed(Speed.parse('80/[90]'), '80/[90]');
    });

    test('parse_whenThreeSpeedsWithSquare_thenCreatesThreeCorrectSpeeds', () {
      _expectIncomingOutgoingSpeed(Speed.parse('[90]/80-70'), '[90]/80-70');
    });

    test('parse_whenXX_thenCreatesSpeedWithXXValue', () {
      _expectIncomingOutgoingSpeed(Speed.parse('XX/70-60-50'), 'XX/70-60-50');
    });

    test('parse_whenInvalidFormat_thenThrowsFormatException', () {
      expect(() => Speed.parse('50-5gj'), throwsFormatException);
    });

    test('parse_whenLeadingSeparator_thenThrowsFormatException', () {
      expect(() => Speed.parse('/93-12'), throwsFormatException);
    });

    test('parse_whenOnlySeparator_thenThrowsFormatException', () {
      expect(() => Speed.parse('/'), throwsFormatException);
    });

    test('parse_whenInvalidCharacters_thenThrowsFormatException', () {
      expect(() => Speed.parse('87-23/ikj'), throwsFormatException);
    });

    test('toString_whenCalled_thenReturnsFormattedString', () {
      // ARRANGE
      final speed = Speed.parse('90/80');
      final expectedString =
          'IncomingOutgoingSpeed('
          'incoming: SingleSpeed(value: 90, isSquared: false, isCircled: false), '
          'outgoing: SingleSpeed(value: 80, isSquared: false, isCircled: false))';

      // ACT & EXPECT
      expect(speed.toString(), equals(expectedString));
    });

    test('equality_whenEqual_shouldReturnTrue', () {
      // ARRANGE
      final a = Speed.parse('120/60');
      final b = Speed.parse('120/60');

      // ACT & EXPECT
      expect(a, equals(b));
    });

    test('equality_whenNotEqual_shouldReturnFalse', () {
      // ARRANGE
      final a = Speed.parse('120/80');
      final b = Speed.parse('120/60');

      // ACT & EXPECT
      expect(a == b, isFalse);
    });
  });
}

void _expectIncomingOutgoingSpeed(Speed result, String expected) {
  expect(result, isA<IncomingOutgoingSpeed>());
  result as IncomingOutgoingSpeed;

  final inOutSpeeds = expected.split('/').map(Speed.parse).toList();

  expect(result.incoming, inOutSpeeds[0]);
  expect(result.outgoing, inOutSpeeds[1]);
}
