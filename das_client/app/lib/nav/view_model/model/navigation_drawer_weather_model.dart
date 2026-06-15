import 'package:weather/component.dart';

sealed class NavigationDrawerWeatherModel {
  const NavigationDrawerWeatherModel();
}

class NavigationDrawerWeatherLoading extends NavigationDrawerWeatherModel {
  const NavigationDrawerWeatherLoading();
}

class NavigationDrawerWeatherData extends NavigationDrawerWeatherModel {
  const NavigationDrawerWeatherData({required this.temperatureCelsius, required this.condition});

  final double temperatureCelsius;
  final WeatherCondition condition;
}

class NavigationDrawerWeatherError extends NavigationDrawerWeatherModel {
  const NavigationDrawerWeatherError();
}
