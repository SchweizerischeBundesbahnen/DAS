import 'package:core_data/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_properties/component.dart';

class MockUserPropertiesRepository implements UserPropertiesRepository {
  final Map<LocalKeyValueStoreKeys, Object> _properties = {};

  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  @override
  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  @override
  Future<void> syncUserProperties() async {}

  @override
  Future<void> saveUserProperty(LocalKeyValueStoreKeys key, Object? value) async {
    if (value == null) {
      _properties.remove(key);
    } else {
      _properties[key] = value;
    }
    _rxModel.add(key);
  }

  @override
  Future<void> clearLocalUserProperties() async {
    _properties.clear();
    _rxModel.add(null);
  }

  T _get<T>(LocalKeyValueStoreKeys key, T defaultValue) => (_properties[key] as T?) ?? defaultValue;

  @override
  bool get showDecisiveGradient => _get(.showDecisiveGradient, true);

  @override
  bool get showStationSignals => _get(.showStationSignals, true);

  @override
  bool get showEctsConventionalSpeedSignals => _get(.showEctsConventionalSpeedSignals, true);

  @override
  bool get showEctsExtendedSpeedSignals => _get(.showEctsExtendedSpeedSignals, true);

  @override
  List<String> get companyCodes => List<String>.from(_get<List<dynamic>>(.companyCodes, const []));

  @override
  TourSystem? get tourSystem => TourSystem.values.asNameMap()[_get<String?>(.tourSystem, null)];

  @override
  String? get lastUsedCompanyCode => _get<String?>(.lastUsedCompanyCode, null);

  @override
  bool get lastSettingsRequestSuccessful => _get(.lastSettingsRequestSuccessful, false);

  @override
  DateTime? get lastSuccessfulSettingsTimestamp => DateTime.tryParse(_get(.lastSuccessfulSettingsTimestamp, ''));

  @override
  DateTime? get lastUserPropertiesSyncTimestamp => DateTime.tryParse(_get(.lastUserPropertiesSyncTimestamp, ''));

  @override
  Future<void> dispose() => _rxModel.close();
}
