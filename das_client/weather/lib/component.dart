import 'package:http_x/component.dart';
import 'package:weather/src/api/open_meteo_weather_api_service_impl.dart';
import 'package:weather/src/repository/weather_repository.dart';
import 'package:weather/src/repository/weather_repository_impl.dart';

export 'package:weather/src/model/weather_condition.dart';
export 'package:weather/src/model/weather_snapshot.dart';
export 'package:weather/src/repository/weather_repository.dart';

class WeatherComponent {
  const WeatherComponent._();

  static WeatherRepository createRepository({
    required double latitude,
    required double longitude,
    required Client client,
    Duration refreshInterval = const Duration(minutes: 15),
  }) {
    return WeatherRepositoryImpl(
      apiService: OpenMeteoWeatherApiServiceImpl(httpClient: client),
      latitude: latitude,
      longitude: longitude,
      refreshInterval: refreshInterval,
    );
  }
}
