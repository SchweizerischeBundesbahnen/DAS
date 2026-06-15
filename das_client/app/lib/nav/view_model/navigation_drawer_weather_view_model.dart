import 'dart:async';

import 'package:app/nav/view_model/model/navigation_drawer_weather_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather/component.dart';

final _log = Logger('NavigationDrawerWeatherViewModel');

class NavigationDrawerWeatherViewModel {
  NavigationDrawerWeatherViewModel({required this._weatherRepository}) {
    _weatherSubscription = _weatherRepository.weatherStream.listen(_onWeatherStateChanged);
    _onWeatherStateChanged(_weatherRepository.weatherValue);
  }

  final WeatherRepository _weatherRepository;
  final _rxModel = BehaviorSubject<NavigationDrawerWeatherModel>.seeded(const NavigationDrawerWeatherLoading());

  StreamSubscription<WeatherRepositoryState>? _weatherSubscription;

  Stream<NavigationDrawerWeatherModel> get model => _rxModel.stream.distinct();

  NavigationDrawerWeatherModel get modelValue => _rxModel.value;

  Future<void> refresh() => _weatherRepository.refresh();

  void dispose() {
    _log.fine('Disposing weather view model');
    _weatherSubscription?.cancel();
    _weatherSubscription = null;
    _rxModel.close();
  }

  void _onWeatherStateChanged(WeatherRepositoryState state) {
    final model = switch (state) {
      WeatherLoading() => const NavigationDrawerWeatherLoading(),
      WeatherAvailable(snapshot: final snapshot) => NavigationDrawerWeatherData(
        temperatureCelsius: snapshot.temperatureCelsius,
        condition: snapshot.condition,
      ),
      WeatherError() => const NavigationDrawerWeatherError(),
    };

    _rxModel.add(model);
  }
}
