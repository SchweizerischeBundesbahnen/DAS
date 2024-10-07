# DAS Client

DAS (Driver Advisory System) is a mobile application that provides all the required journey data to the train driver.

## Supported platforms

<div id="supported_platforms">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS">
</div>

## Build and run

DAS Client has 3 distinct flavors: `dev`, `inte` and `prod`. Run them as follows:

```shell
fvm flutter run --flavor dev -t lib/main_dev.dart
```

```shell
fvm flutter run --flavor inte -t lib/main_inte.dart
```

```shell
fvm flutter run --flavor prod -t lib/main_prod.dart
```

## Running Integration Tests

Instrumentation Tests do not use user authentication. Therefore the credentials must be provided as environment variables.

```shell
fvm flutter test --flavor dev --dart-define=MQTT_USERNAME=${MQTT_USERNAME} --dart-define=MQTT_PASSWORD=${MQTT_PASSWORD} integration_test/app_test.dart
```

## Architecture

TODO

<a name="localization"></a>
## Localization

The app is available in three languages:

<div id="supported_languages">
  <img src="https://img.shields.io/badge/default-%F0%9F%87%A9%F0%9F%87%AA_german_(de)-999999?style=for-the-badge" alt="German"/>
  <img src="https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7_french_(fr)-999999?style=for-the-badge" alt="French"/>
  <img src="https://img.shields.io/badge/%F0%9F%87%AE%F0%9F%87%B9_italian_(it)-999999?style=for-the-badge" alt="Italian"/>
</div>

## Code style

This application uses the code style defined in the [Flutter Wiki][2]. The
recommendations are mandatory and should always be followed unless there is a
good reason not to do so. However, this must be approved by all developers.

## Flutter SDK version

This app uses [FVM][1] to configure the Flutter SDK version.

[1]:https://fvm.app/
[2]:https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md
