import 'package:weather/src/model/weather_snapshot.dart';

sealed class WeatherRepositoryState {
  const WeatherRepositoryState();
}

class WeatherLoading extends WeatherRepositoryState {
  const WeatherLoading();
}

class WeatherAvailable extends WeatherRepositoryState {
  const WeatherAvailable(this.snapshot);

  final WeatherSnapshot snapshot;
}

class WeatherError extends WeatherRepositoryState {
  const WeatherError(this.error);

  final Object error;
}

abstract class WeatherRepository {
  const WeatherRepository._();

  Stream<WeatherRepositoryState> get weatherStream;

  WeatherRepositoryState get weatherValue;

  Future<void> refresh();

  void dispose();
}
