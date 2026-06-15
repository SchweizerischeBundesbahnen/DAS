import 'dart:async';
import 'dart:convert';
import 'package:app/weather/weather_model.dart';
import 'package:http_x/component.dart';
import 'package:logging/logging.dart';

final _log = Logger('WeatherService');

class WeatherService {
  final Client httpClient;

  WeatherService({required this.httpClient});

  static const String _apiBaseUrl = 'https://api.open-meteo.com/v1';
  static const double _latitude = 47.5596;  // Switzerland (Bern)
  static const double _longitude = 7.5886;

  /// Fetches current weather data
  /// Returns null if the request fails
  Future<WeatherData?> getCurrentWeather() async {
    try {
      _log.fine('Fetching weather data');

      final uri = Uri.parse(
        '$_apiBaseUrl/forecast?'
        'latitude=$_latitude&'
        'longitude=$_longitude&'
        'current=temperature_2m,weather_code&'
        'temperature_unit=celsius&'
        'timezone=auto',
      );

      final response = await httpClient.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(jsonData);
      } else {
        _log.warning('Failed to fetch weather: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log.warning('Error fetching weather: $e');
      return null;
    }
  }

  /// Fetches weather data with periodic updates
  /// Updates every 5 minutes or on demand
  Stream<WeatherData> getWeatherStream({Duration updateInterval = const Duration(minutes: 5)}) async* {
    final initialWeather = await getCurrentWeather();
    if (initialWeather != null) {
      yield initialWeather;
    }

    // Emit periodic updates
    await for (final _ in Stream.periodic(updateInterval)) {
      final weather = await getCurrentWeather();
      if (weather != null) {
        yield weather;
      }
    }
  }
}

