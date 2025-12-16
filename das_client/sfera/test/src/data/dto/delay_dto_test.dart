import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/dto/delay_dto.dart';

void main() {
  test('Test correct conversion from String to duration with the delay being PT0M25S', () async {
    final delay = DelayDto(attributes: {'Delay': 'PT0M25S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, false);
    expect(convertedDelay.inMinutes, 0);
    expect(convertedDelay.inSeconds, 25);
  });

  test('Test correct conversion from String to duration with negative delay', () async {
    final delay = DelayDto(attributes: {'Delay': '-PT3M5S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, true);
    expect(convertedDelay.inMinutes, -3);
    expect(convertedDelay.inSeconds, -185);
  });

  test('Test null delay conversion to null duration', () async {
    final delay = DelayDto();
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNull);
  });

  test('Test empty String conversion to null duration', () async {
    final delay = DelayDto(attributes: {'Delay': ''});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNull);
  });

  test('Test big delay String over one hour conversion to correct duration', () async {
    final delay = DelayDto(attributes: {'Delay': 'PT5H45M20S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, false);
    expect(convertedDelay.inHours, 5);
    expect(convertedDelay.inMinutes, 345);
    expect(convertedDelay.inSeconds, 20720);
  });

  test('Test only seconds conversion to correct duration', () async {
    final delay = DelayDto(attributes: {'Delay': 'PT14S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, false);
    expect(convertedDelay.inSeconds, 14);
  });

  test('Test wrong ISO 8601 format String conversion to null duration', () async {
    final delay = DelayDto(attributes: {'Delay': '+PTH45S3434M334'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNull);
  });
}
