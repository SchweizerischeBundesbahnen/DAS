import 'dart:convert';

import 'package:app/model/tour_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_properties/src/api/model/user_property_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

//erweitern dass es auch ein lastUpdate hat. jedesmal beim set. beim get beides zurück im user property repo integrieren mit set und get
//sync methode geht alle keys durch (getAllKeys machen im store mit key name value und date) und backend getten und ein diff builden
//the newest version overwrites the older
// when set is called, sync.
//sync once the app starts / after login
//when sync fails try 5 minutes later again
//when logout all local user properties need to be deleted

/*
  * Umstrukturieren, local key value store zum andern package (api anfrage von user_property) und nach aussen immer nur value, nicht last updated.
  * Nach aussen nicht UserPropertyModel
  * integrieren in user_propertie_repository gegen aussen nur das!
  * repo = save und get mit key und nur value kommt zurück
  * keys -> auch ins andere repo
  * model muss nicht exported werden
  * */

class LocalKeyValueStore() {
  this {
    _init();
  }

  late SharedPreferences _prefs;
  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  void _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserPropertyModel get<T>(LocalKeyValueStoreKeys key, T defaultValue) {
    final rawString = _prefs.getString(key.name);

    if (rawString == null) {
      return UserPropertyModel(lastUpdated: null, value: defaultValue.toString());
    }

    final json = jsonDecode(rawString);

    return UserPropertyModel.fromJson(json);
  }

  bool convertToBool(String? currentValue) {
    if (currentValue == 'true' || currentValue == null) {
      return true;
    } else {
      return false;
    }
  }

  TourSystem? convertToTourSystem(String? currentValue) {
    if (currentValue == null) return null;
    return TourSystem.values.firstWhereOrNull((it) => it.name == currentValue);
  }

  T convertedValue<T>(LocalKeyValueStoreKeys key, String? currentValue) {
    if (currentValue == null) return null as T;

    switch (key) {
      case LocalKeyValueStoreKeys.showDecisiveGradient:
        return convertToBool(currentValue) as T;
      case LocalKeyValueStoreKeys.showStationSignals:
        return convertToBool(currentValue) as T;
      case LocalKeyValueStoreKeys.showEctsConventionalSpeedSignals:
        return convertToBool(currentValue) as T;
      case LocalKeyValueStoreKeys.showEctsExtendedSpeedSignals:
        return convertToBool(currentValue) as T;
      case LocalKeyValueStoreKeys.lastSettingsRequestSuccessful:
        return convertToBool(currentValue) as T;
      case LocalKeyValueStoreKeys.companyCodes:
        return (jsonDecode(currentValue) as List).cast<String>() as T;
      case LocalKeyValueStoreKeys.tourSystem:
        return convertToTourSystem(currentValue) as T;
      case LocalKeyValueStoreKeys.lastUsedCompanyCode:
        return currentValue as T;
      case LocalKeyValueStoreKeys.lastSuccessfulSettingsTimestamp:
        return currentValue as T;
    }
  }

  Future<void> set<T>(LocalKeyValueStoreKeys key, T value) async {
    if (value == null) {
      await _prefs.remove(key.name);
    }

    final valueProperty = UserPropertyModel(lastUpdated: DateTime.now(), value: value.toString());
    final thomas = jsonEncode(valueProperty.toJson());

    _prefs.setString(key.name, thomas);
    _rxModel.add(key);
  }

  bool get showDecisiveGradient =>
      convertedValue(LocalKeyValueStoreKeys.showDecisiveGradient, get(.showDecisiveGradient, true).value);

  bool get showStationSignals =>
      convertedValue(LocalKeyValueStoreKeys.showStationSignals, get(.showStationSignals, true).value);

  bool get showEctsConventionalSpeedSignals => convertedValue(
    LocalKeyValueStoreKeys.showEctsConventionalSpeedSignals,
    get(.showEctsConventionalSpeedSignals, true).value,
  );

  bool get showEctsExtendedSpeedSignals => convertedValue(
    LocalKeyValueStoreKeys.showEctsExtendedSpeedSignals,
    get(.showEctsExtendedSpeedSignals, true).value,
  );

  List<String> get companyCodes =>
      List<String>.from(convertedValue(LocalKeyValueStoreKeys.companyCodes, get(.companyCodes, []).value));

  TourSystem? get tourSystem => convertedValue<TourSystem?>(
    LocalKeyValueStoreKeys.tourSystem,
    get<String?>(LocalKeyValueStoreKeys.tourSystem, null).value,
  );

  String? get lastUsedCompanyCode =>
      convertedValue(LocalKeyValueStoreKeys.lastUsedCompanyCode, get<String?>(.lastUsedCompanyCode, null).value);

  bool get lastSettingsRequestSuccessful => convertedValue(
    LocalKeyValueStoreKeys.lastSettingsRequestSuccessful,
    get<bool>(.lastSettingsRequestSuccessful, false).value,
  );

  DateTime? get lastSuccessfulSettingsTimestamp {
    final dateString = convertedValue(
      LocalKeyValueStoreKeys.lastSuccessfulSettingsTimestamp,
      get<String?>(.lastSuccessfulSettingsTimestamp, null).value,
    );
    return DateTime.tryParse(dateString);
  }

  void dispose() {
    _rxModel.close();
  }
}

enum LocalKeyValueStoreKeys {
  showDecisiveGradient,
  companyCodes,
  tourSystem,
  showStationSignals,
  showEctsConventionalSpeedSignals,
  showEctsExtendedSpeedSignals,
  lastUsedCompanyCode,
  lastSettingsRequestSuccessful,
  lastSuccessfulSettingsTimestamp,
}
