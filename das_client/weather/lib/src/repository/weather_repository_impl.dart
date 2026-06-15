import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather/src/api/open_meteo_weather_api_service.dart';
import 'package:weather/src/repository/weather_repository.dart';

final _log = Logger('WeatherRepositoryImpl');

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    required this._apiService,
    required this._latitude,
    required this._longitude,
    required this._refreshInterval,
  }) {
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => refresh());
    unawaited(refresh());
  }

  final OpenMeteoWeatherApiService _apiService;
  final double _latitude;
  final double _longitude;
  final Duration _refreshInterval;

  Timer? _refreshTimer;
  final _rxState = BehaviorSubject<WeatherRepositoryState>.seeded(const WeatherLoading());

  @override
  Stream<WeatherRepositoryState> get weatherStream => _rxState.stream.distinct();

  @override
  WeatherRepositoryState get weatherValue => _rxState.value;

  @override
  Future<void> refresh() async {
    try {
      final weather = await _apiService.fetchCurrentWeather(latitude: _latitude, longitude: _longitude);
      _rxState.add(WeatherAvailable(weather));
      _log.fine('Weather refreshed successfully.');
    } catch (e) {
      _rxState.add(WeatherError(e));
      _log.warning('Error while loading weather from Open-Meteo.', e);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _apiService.dispose();
    _rxState.close();
  }
}
