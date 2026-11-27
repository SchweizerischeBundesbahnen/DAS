import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_properties/src/api/model/user_property_model.dart';
import 'package:user_properties/src/provider/user_id_provider_properties.dart';

class LocalKeyValueStore {
  LocalKeyValueStore({required this._userIdProvider}) {
    _ready = _init();
  }

  static final Set<String> syncedKeyNames = {
    for (final key in LocalKeyValueStoreKeys.values)
      if (!_localOnlyKeys.contains(key)) key.name,
  };

  static const _localOnlyKeys = {
    LocalKeyValueStoreKeys.lastSettingsRequestSuccessful,
    LocalKeyValueStoreKeys.lastSuccessfulSettingsTimestamp,
    LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp,
  };

  late final SharedPreferences _prefs;
  late final Future<void> _ready;
  final UserIdProviderProperties _userIdProvider;
  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  String? _userId;

  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  Future<void> get ready => _ready;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<String> _ensureUserId() async {
    final cached = _userId;
    if (cached != null) return cached;

    final userId = await _userIdProvider();
    _userId = userId;
    _rxModel.add(null);
    return userId;
  }

  String _prefsKey(String userId, String key) => '$userId-$key';

  UserPropertyModel get<T>(LocalKeyValueStoreKeys key, T defaultValue) =>
      _read(key.name) ?? UserPropertyModel(key: key.name, lastUpdated: null, value: defaultValue);

  Future<void> set<T>(LocalKeyValueStoreKeys key, T value) async {
    await _ready;
    await put(UserPropertyModel(key: key.name, lastUpdated: clock.now().toUtc(), value: value));
  }

  Future<void> put(UserPropertyModel model) async {
    await _ready;
    final userId = await _ensureUserId();

    if (model.value == null) {
      await _prefs.remove(_prefsKey(userId, model.key));
    } else {
      await _prefs.setString(_prefsKey(userId, model.key), jsonEncode(model.toJson()));
    }

    _rxModel.add(LocalKeyValueStoreKeys.values.asNameMap()[model.key]);
  }

  Future<void> delete(LocalKeyValueStoreKeys key) async {
    await _ready;
    final userId = await _ensureUserId();
    await _prefs.remove(_prefsKey(userId, key.name));
    _rxModel.add(key);
  }

  Future<List<UserPropertyModel>> getAllLocalUserProperties() async {
    await _ready;
    await _ensureUserId();
    return [
      for (final key in syncedKeyNames) ?_read(key),
    ];
  }

  Future<void> clearUserProperties() async {
    await _ready;
    final userId = await _ensureUserId();

    for (final key in syncedKeyNames) {
      await _prefs.remove(_prefsKey(userId, key));
    }
    await _prefs.remove(_prefsKey(userId, LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp.name));

    _rxModel.add(null);
  }

  UserPropertyModel? _read(String key) {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final raw = _prefs.getString(_prefsKey(userId, key));
      if (raw == null) return null;

      final json = Map<String, dynamic>.from(jsonDecode(raw) as Map)..putIfAbsent('key', () => key);
      return UserPropertyModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastUserPropertiesSyncTimestamp(DateTime? timestamp) {
    return set(LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp, timestamp?.toIso8601String());
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
  lastUserPropertiesSyncTimestamp,
}
