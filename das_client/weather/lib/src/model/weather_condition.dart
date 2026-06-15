enum WeatherCondition {
  clear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
  unknown,
}

extension WeatherConditionCodeMapper on WeatherCondition {
  static WeatherCondition fromCode(int weatherCode) => switch (weatherCode) {
    0 => WeatherCondition.clear,
    1 || 2 => WeatherCondition.partlyCloudy,
    3 => WeatherCondition.overcast,
    45 || 48 => WeatherCondition.fog,
    51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
    61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherCondition.rain,
    71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snow,
    95 || 96 || 99 => WeatherCondition.thunderstorm,
    _ => WeatherCondition.unknown,
  };
}
