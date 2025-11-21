import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/speed.dart';

void main() {
  group('UnitTest GraduatedSpeed', () {
    test('parse_whenThreePlainSpeeds_thenCreatesThreeCorrectSpeeds', () {
      _expectGraduatedSpeed(Speed.parse('80-90-100'), '80-90-100');
    });

    test('parse_whenThreeSpeedsWithSquare_thenCreatesThreeCorrectSpeeds', () {
      _expectGraduatedSpeed(Speed.parse('[90]-80-70'), '[90]-80-70');
    });

    test('parse_whenTwoSpeedsWithCurlyBrackets_thenCreatesCorrectSpeeds', () {
      _expectGraduatedSpeed(Speed.parse('{100}-80'), '{100}-80');
    });

    test('parse_whenTwoSpeedsWithCurlyBracketsAndWhitespace_thenCreatesCorrectSpeeds', () {
      _expectGraduatedSpeed(Speed.parse(' {100 }- 80'), '{100}-80');
    });

    test('parse_whenXX_thenCreatesSpeedWithXXValue', () {
      _expectGraduatedSpeed(Speed.parse('XX-70-60'), 'XX-70-60');
    });

    test('parse_whenInvalidFormat_thenThrowsFormatException', () {
      expect(() => Speed.parse('50-5gj'), throwsFormatException);
    });

    test('parse_whenLeadingSeparator_thenThrowsFormatException', () {
      expect(() => Speed.parse('-93-12'), throwsFormatException);
    });

    test('parse_whenOnlySeparator_thenThrowsFormatException', () {
      expect(() => Speed.parse('-'), throwsFormatException);
    });

    test('parse_whenInvalidCharacters_thenThrowsFormatException', () {
      expect(() => Speed.parse('87-23-ikj'), throwsFormatException);
    });

    test('toString_whenCalled_thenReturnsFormattedString', () {
      // ARRANGE
      final speed = Speed.parse('90-80');
      final expectedString =
          'GraduatedSpeed{speeds: '
          '[SingleSpeed{value: 90, isSquared: false, isCircled: false}, '
          'SingleSpeed{value: 80, isSquared: false, isCircled: false}]}';

      // ACT & EXPECT
      expect(speed.toString(), equals(expectedString));
    });

    test('equality_whenEqual_shouldReturnTrue', () {
      // ARRANGE
      final a = Speed.parse('120-60');
      final b = Speed.parse('120-60');

      // ACT & EXPECT
      expect(a, equals(b));
    });

    test('equality_whenNotEqual_shouldReturnFalse', () {
      // ARRANGE
      final a = Speed.parse('120-80');
      final b = Speed.parse('120-60');

      // ACT & EXPECT
      expect(a == b, isFalse);
    });
  });
}

void _expectGraduatedSpeed(Speed result, String expected) {
  expect(result, isA<GraduatedSpeed>());
  result as GraduatedSpeed;

  final singleSpeeds = expected.split('-').map(Speed.parse).toList();

  expect(result.speeds, hasLength(singleSpeeds.length));
  expect(ListEquality().equals(result.speeds, singleSpeeds), isTrue);
}
