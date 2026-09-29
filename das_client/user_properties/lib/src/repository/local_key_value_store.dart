import 'dart:convert';

import 'package:core_data/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:user_properties/src/api/model/user_property_model.dart';

class LocalKeyValueStore() {
  this {
    _ready = _init();
  }

  late SharedPreferences _prefs;
  late final Future<void> _ready;
  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  static const _localOnlyKeys = {
    LocalKeyValueStoreKeys.lastSettingsRequestSuccessful,
    LocalKeyValueStoreKeys.lastSuccessfulSettingsTimestamp,
    LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp,
  };

  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  Future<void> get ready => _ready;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserPropertyModel get<T>(LocalKeyValueStoreKeys key, T defaultValue) {
    final rawString = _prefs.getString(key.name);

    if (rawString == null) {
      return UserPropertyModel(key: key.name, lastUpdated: null, value: defaultValue);
    }

    final json = Map<String, dynamic>.from(jsonDecode(rawString) as Map);
    json.putIfAbsent('key', () => key.name);

    return UserPropertyModel.fromJson(json);
  }

  Future<void> set<T>(LocalKeyValueStoreKeys key, T value) async {
    await _ready;

    if (value == null) {
      await _prefs.remove(key.name);
      _rxModel.add(key);
      return;
    }

    final valueProperty = UserPropertyModel(key: key.name, lastUpdated: DateTime.now(), value: value);
    final jsonEncodedProperty = jsonEncode(valueProperty.toJson());

    await _prefs.setString(key.name, jsonEncodedProperty);
    _rxModel.add(key);
  }

  List<UserPropertyModel> getAllLocalUserProperties() {
    return _prefs
        .getKeys()
        .where((key) => !_localOnlyKeys.contains(key))
        .map((key) {
          final rawString = _prefs.getString(key);
          if (rawString == null) return null;

          try {
            final json = Map<String, dynamic>.from(jsonDecode(rawString) as Map);
            json.putIfAbsent('key', () => key);
            return UserPropertyModel.fromJson(json);
          } catch (_) {
            return null;
          }
        })
        .nonNulls
        .toList(growable: false);
  }

  Future<void> put(UserPropertyModel model) async {
    await _ready;

    if (model.value == null) {
      await _prefs.remove(model.key);
      _emitChangeForKeyName(model.key);
      return;
    }

    final encoded = jsonEncode(model.toJson());
    await _prefs.setString(model.key, encoded);
    _emitChangeForKeyName(model.key);
  }

  Future<void> delete(LocalKeyValueStoreKeys key) async {
    await _ready;
    await _prefs.remove(key.name);
    _emitChangeForKeyName(key.name);
  }

  Future<void> clearUserProperties() async {
    await ready;

    for (final property in getAllLocalUserProperties()) {
      await _prefs.remove(property.key);
    }

    await _prefs.remove(LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp.name);
    _rxModel.add(null);
  }

  List<String> _convertToList(Object? value) => switch (value) {
    final List<dynamic> list => List<String>.from(list),
    final String json => List<String>.from(jsonDecode(json) as List),
    _ => throw StateError('Unexpected companyCodes value: $value'),
  };

  TourSystem? _convertToTourSystem(Object? currentValue) {
    if (currentValue == null) return null;
    return TourSystem.values.firstWhereOrNull((it) => it.name == currentValue.toString());
  }

  bool get showDecisiveGradient => get(.showDecisiveGradient, true).value as bool;

  bool get showStationSignals => get(.showStationSignals, true).value as bool;

  bool get showEctsConventionalSpeedSignals => get(.showEctsConventionalSpeedSignals, true).value as bool;

  bool get showEctsExtendedSpeedSignals => get(.showEctsExtendedSpeedSignals, true).value as bool;

  List<String> get companyCodes => List<String>.from(_convertToList(get(.companyCodes, []).value));

  TourSystem? get tourSystem => _convertToTourSystem(get<String?>(LocalKeyValueStoreKeys.tourSystem, null).value);

  String? get lastUsedCompanyCode => get<String?>(.lastUsedCompanyCode, null).value as String?;

  bool get lastSettingsRequestSuccessful => get<bool>(.lastSettingsRequestSuccessful, false).value as bool;

  DateTime? get lastSuccessfulSettingsTimestamp {
    final dateString = get<String?>(.lastSuccessfulSettingsTimestamp, null).value as String;
    return DateTime.tryParse(dateString);
  }

  DateTime? get lastUserPropertiesSyncTimestamp {
    final dateString = get<String?>(.lastUserPropertiesSyncTimestamp, null).value as String;
    return DateTime.tryParse(dateString);
  }

  Future<void> setLastUserPropertiesSyncTimestamp(DateTime? timestamp) {
    return set(LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp, timestamp?.toIso8601String());
  }

  void dispose() {
    _rxModel.close();
  }

  void _emitChangeForKeyName(String key) {
    _rxModel.add(LocalKeyValueStoreKeys.values.firstWhereOrNull((it) => it.name == key));
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
  lastUserPropertiesSyncTimestamp,
}
