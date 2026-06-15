import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:weather/src/api/open_meteo_weather_api_service.dart';
import 'package:weather/src/model/weather_condition.dart';
import 'package:weather/src/model/weather_snapshot.dart';

class OpenMeteoWeatherApiServiceImpl implements OpenMeteoWeatherApiService {
  OpenMeteoWeatherApiServiceImpl({required this.httpClient});

  final Client httpClient;

  @override
  Future<WeatherSnapshot> fetchCurrentWeather({required double latitude, required double longitude}) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,weather_code',
      'timezone': 'auto',
    });

    final response = await httpClient.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException.fromResponse(response);
    }

    final dynamic decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object as response body.');
    }

    final current = decodedBody['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Missing "current" weather data in Open-Meteo response.');
    }

    final temperatureValue = current['temperature_2m'];
    final weatherCodeValue = current['weather_code'];

    if (temperatureValue is! num || weatherCodeValue is! int) {
      throw const FormatException('Missing or invalid temperature/weather code in Open-Meteo response.');
    }

    return WeatherSnapshot(
      temperatureCelsius: temperatureValue.toDouble(),
      condition: WeatherConditionCodeMapper.fromCode(weatherCodeValue),
      fetchedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    httpClient.close();
  }
}
