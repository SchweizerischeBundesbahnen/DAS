import 'package:app/model/tour_system.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalKeyValueStore {
  LocalKeyValueStore() {
    _init();
  }

  late SharedPreferences _prefs;
  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  void _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  T get<T>(LocalKeyValueStoreKeys key, T defaultValue) {
    return _prefs.get(key.name) as T? ?? defaultValue;
  }

  Future<void> set<T>(LocalKeyValueStoreKeys key, T value) async {
    if (value == null) {
      await _prefs.remove(key.name);
    } else if (value is bool) {
      await _prefs.setBool(key.name, value);
    } else if (value is int) {
      await _prefs.setInt(key.name, value);
    } else if (value is double) {
      await _prefs.setDouble(key.name, value);
    } else if (value is String) {
      await _prefs.setString(key.name, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key.name, value);
    } else {
      throw ArgumentError('Unsupported type for user setting: ${value.runtimeType}');
    }
    _rxModel.add(key);
  }

  bool get showDecisiveGradient => get(.showDecisiveGradient, true);

  bool get showStationSignals => get(.showStationSignals, true);

  bool get showEctsConventionalSpeedSignals => get(.showEctsConventionalSpeedSignals, true);

  bool get showEctsExtendedSpeedSignals => get(.showEctsExtendedSpeedSignals, true);

  List<String> get companyCodes => get(.companyCodes, []);

  TourSystem? get tourSystem {
    final tourSystemName = get<String?>(.tourSystem, null);
    return TourSystem.values.firstWhereOrNull((it) => it.name == tourSystemName);
  }

  String? get lastUsedCompanyCode => get<String?>(.lastUsedCompanyCode, null);

  bool get lastSettingsRequestSuccessful => get<bool>(.lastSettingsRequestSuccessful, false);

  DateTime? get lastSuccessfulSettingsTimestamp {
    final dateString = get<String?>(.lastSuccessfulSettingsTimestamp, null);
    return dateString != null ? DateTime.tryParse(dateString) : null;
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
