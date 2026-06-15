class WeatherData {
  final double temperature;
  final String condition;
  final int weatherCode;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.weatherCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    final temperature = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;

    final condition = _getWeatherCondition(weatherCode);

    return WeatherData(
      temperature: temperature,
      condition: condition,
      weatherCode: weatherCode,
    );
  }

  static String _getWeatherCondition(int code) {
    // WMO Weather interpretation codes
    switch (code) {
      case 0:
        return 'Sunny';
      case 1 || 2:
        return 'Mostly Sunny';
      case 3:
        return 'Cloudy';
      case 45 || 48:
        return 'Foggy';
      case 51 || 53 || 55:
        return 'Light Rain';
      case 61 || 63 || 65:
        return 'Rainy';
      case 71 || 73 || 75 || 77:
        return 'Snowy';
      case 80 || 81 || 82:
        return 'Rain Showers';
      case 85 || 86:
        return 'Snow Showers';
      case 95 || 96 || 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}

