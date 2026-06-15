import 'package:flutter_test/flutter_test.dart';
import 'package:weather/component.dart';

void main() {
  group('WeatherConditionCodeMapper', () {
    test('fromCode_whenClearAndCloudCodes_thenMapsExpectedCondition', () {
      expect(WeatherConditionCodeMapper.fromCode(0), WeatherCondition.clear);
      expect(WeatherConditionCodeMapper.fromCode(2), WeatherCondition.partlyCloudy);
      expect(WeatherConditionCodeMapper.fromCode(3), WeatherCondition.overcast);
    });

    test('fromCode_whenRainAndSnowCodes_thenMapsExpectedCondition', () {
      expect(WeatherConditionCodeMapper.fromCode(61), WeatherCondition.rain);
      expect(WeatherConditionCodeMapper.fromCode(75), WeatherCondition.snow);
      expect(WeatherConditionCodeMapper.fromCode(95), WeatherCondition.thunderstorm);
    });

    test('fromCode_whenUnknownCode_thenMapsToUnknown', () {
      expect(WeatherConditionCodeMapper.fromCode(999), WeatherCondition.unknown);
    });
  });
}
