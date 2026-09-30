import 'package:core_data/component.dart';
import 'package:user_properties/component.dart';

abstract interface class UserPropertiesRepository {
  Future<void> syncUserProperties();

  Future<void> saveUserProperty(LocalKeyValueStoreKeys key, Object? value);

  Future<void> deleteUserProperty(LocalKeyValueStoreKeys key);

  Future<void> clearLocalUserProperties();

  bool get showDecisiveGradient;

  bool get showStationSignals;

  bool get showEctsConventionalSpeedSignals;

  bool get showEctsExtendedSpeedSignals;

  List<String> get companyCodes;

  TourSystem? get tourSystem;

  String? get lastUsedCompanyCode;

  bool get lastSettingsRequestSuccessful;

  DateTime? get lastSuccessfulSettingsTimestamp;

  DateTime? get lastUserPropertiesSyncTimestamp;

  Stream<LocalKeyValueStoreKeys?> get model;

  void dispose();
}
