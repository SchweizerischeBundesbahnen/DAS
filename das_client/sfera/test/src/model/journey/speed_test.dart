import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/speed.dart';

void main() {
  group('UnitTest Speed', () {
    test('parse_whenPlainDigits_thenCreatesSpeedWithNoDecorations', () {
      _expectSpeed(Speed.parse('80'), '80');
    });

    test('parse_whenSquareBrackets_thenCreatesSpeedWithSquaredTrue', () {
      _expectSpeed(Speed.parse('[90]'), '90', isSquared: true);
    });

    test('parse_whenCurlyBrackets_thenCreatesSpeedWithCircledTrue', () {
      _expectSpeed(Speed.parse('{100}'), '100', isCircled: true);
    });

    test('parse_whenXX_thenCreatesSpeedWithXXValue', () {
      _expectSpeed(Speed.parse('XX'), 'XX');
    });

    test('parse_whenXXWithSquareBrackets_thenCreatesSpeedWithXXValueAndSquaredTrue', () {
      _expectSpeed(Speed.parse('[XX]'), 'XX', isSquared: true);
    });

    test('parse_whenXXWithCurlyBrackets_thenCreatesSpeedWithXXValueAndCircledTrue', () {
      _expectSpeed(Speed.parse('{XX}'), 'XX', isCircled: true);
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
      final speed = Speed(value: '120', isSquared: true, isCircled: false);
      final expectedString = 'Speed(value: 120, isSquared: true, isCircled: false)';
      
      // ACT & EXPECT
      expect(speed.toString(), equals(expectedString));
    });
  });
}

void _expectSpeed(Speed result, String actual, {isSquared = false, isCircled = false}) {
  expect(result.value, equals(actual));
  expect(result.isSquared, equals(isSquared));
  expect(result.isCircled, equals(isCircled));
}
