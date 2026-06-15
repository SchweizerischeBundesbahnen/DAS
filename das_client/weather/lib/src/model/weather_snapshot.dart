import 'package:weather/src/model/weather_condition.dart';

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperatureCelsius,
    required this.condition,
    required this.fetchedAt,
  });

  final double temperatureCelsius;
  final WeatherCondition condition;
  final DateTime fetchedAt;

  @override
  String toString() {
    return 'WeatherSnapshot(temperatureCelsius: $temperatureCelsius, condition: $condition, fetchedAt: $fetchedAt)';
  }
}
