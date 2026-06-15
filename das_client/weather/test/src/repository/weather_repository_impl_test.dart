import 'package:flutter_test/flutter_test.dart';
import 'package:weather/src/api/open_meteo_weather_api_service.dart';
import 'package:weather/src/model/weather_condition.dart';
import 'package:weather/src/model/weather_snapshot.dart';
import 'package:weather/src/repository/weather_repository.dart';
import 'package:weather/src/repository/weather_repository_impl.dart';

void main() {
  group('WeatherRepositoryImpl', () {
    test('refresh_whenServiceReturnsWeather_thenEmitsWeatherAvailable', () async {
      final repo = WeatherRepositoryImpl(
        apiService: _FakeApiService(
          snapshotToReturn: WeatherSnapshot(
            temperatureCelsius: 23.0,
            condition: WeatherCondition.clear,
            fetchedAt: DateTime(2026),
          ),
        ),
        latitude: 47.0,
        longitude: 8.0,
        refreshInterval: const Duration(days: 1),
      );

      await repo.refresh();

      expect(repo.weatherValue, isA<WeatherAvailable>());
      repo.dispose();
    });

    test('refresh_whenServiceThrows_thenEmitsWeatherError', () async {
      final repo = WeatherRepositoryImpl(
        apiService: _FakeApiService(errorToThrow: Exception('boom')),
        latitude: 47.0,
        longitude: 8.0,
        refreshInterval: const Duration(days: 1),
      );

      await repo.refresh();

      expect(repo.weatherValue, isA<WeatherError>());
      repo.dispose();
    });
  });
}

class _FakeApiService implements OpenMeteoWeatherApiService {
  _FakeApiService({this.snapshotToReturn, this.errorToThrow});

  final WeatherSnapshot? snapshotToReturn;
  final Object? errorToThrow;

  @override
  Future<WeatherSnapshot> fetchCurrentWeather({required double latitude, required double longitude}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return snapshotToReturn!;
  }

  @override
  void dispose() {}
}
