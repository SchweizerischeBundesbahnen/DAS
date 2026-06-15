# weather

Workspace component for loading current weather from Open-Meteo.

## Features

- Fetches current temperature and weather condition from `https://api.open-meteo.com/v1/forecast`
- Maps Open-Meteo weather codes to a typed `WeatherCondition`
- Provides a reactive `WeatherRepository` stream with loading/success/error states
- Supports periodic refresh

## Example

```dart
import 'package:http_x/component.dart';
import 'package:weather/component.dart';

Future<void> main() async {
  final repository = WeatherComponent.createRepository(
    client: Client(),
    latitude: 47.3769,
    longitude: 8.5417,
  );

  repository.weatherStream.listen(print);
  await repository.refresh();
}
```

