import 'package:weather/src/model/weather_snapshot.dart';

abstract class OpenMeteoWeatherApiService {
  const OpenMeteoWeatherApiService._();

  Future<WeatherSnapshot> fetchCurrentWeather({required double latitude, required double longitude});

  void dispose();
}
