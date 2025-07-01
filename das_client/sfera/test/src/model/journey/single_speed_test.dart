import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/speed.dart';

void main() {
  group('UnitTest SingleSpeed', () {
    test('parse_whenPlainDigits_thenCreatesSpeedWithNoDecorations', () {
      _expectSingleSpeed(Speed.parse('80'), '80');
    });

    test('parse_whenSquareBrackets_thenCreatesSpeedWithSquaredTrue', () {
      _expectSingleSpeed(Speed.parse('[90]'), '90', isSquared: true);
    });

    test('parse_whenCurlyBrackets_thenCreatesSpeedWithCircledTrue', () {
      _expectSingleSpeed(Speed.parse('{100}'), '100', isCircled: true);
    });

    test('parse_whenXX_thenCreatesSpeedWithXXValue', () {
      _expectSingleSpeed(Speed.parse('XX'), 'XX');
    });

    test('parse_whenXXWithSquareBrackets_thenCreatesSpeedWithXXValueAndSquaredTrue', () {
      _expectSingleSpeed(Speed.parse('[XX]'), 'XX', isSquared: true);
    });

    test('parse_whenXXWithCurlyBrackets_thenCreatesSpeedWithXXValueAndCircledTrue', () {
      _expectSingleSpeed(Speed.parse('{XX}'), 'XX', isCircled: true);
    });

    test('parse_whenInvalidFormat_thenThrowsFormatException', () {
      expect(() => Speed.parse('5a0'), throwsFormatException);
    });

    test('parse_whenEmptyString_thenThrowsFormatException', () {
      expect(() => Speed.parse(''), throwsFormatException);
    });

    test('parse_whenInvalidCharacters_thenThrowsFormatException', () {
      expect(() => Speed.parse('(50)'), throwsFormatException);
    });

    test('toString_whenCalled_thenReturnsFormattedString', () {
      // ARRANGE
      final speed = SingleSpeed(value: '120', isSquared: true, isCircled: false);
      final expectedString = 'SingleSpeed(value: 120, isSquared: true, isCircled: false)';

      // ACT & EXPECT
      expect(speed.toString(), equals(expectedString));
    });

    test('equality_whenEqual_shouldReturnTrue', () {
      // ARRANGE
      final a = SingleSpeed(value: '120', isSquared: true, isCircled: false);
      final b = SingleSpeed(value: '120', isSquared: true, isCircled: false);

      // ACT & EXPECT
      expect(a, equals(b));
    });

    test('equality_whenNotEqual_shouldReturnFalse', () {
      // ARRANGE
      final a = SingleSpeed(value: '120', isSquared: true, isCircled: false);
      final b = SingleSpeed(value: '80', isSquared: false, isCircled: false);

      // ACT & EXPECT
      expect(a == b, isFalse);
    });
  });
}

void _expectSingleSpeed(Speed result, String actual, {isSquared = false, isCircled = false}) {
  expect(result, isA<SingleSpeed>());
  result as SingleSpeed;
  expect(result.value, equals(actual));
  expect(result.isSquared, equals(isSquared));
  expect(result.isCircled, equals(isCircled));
}
