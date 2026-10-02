import 'dart:async';
import 'dart:convert';

import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:user_properties/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_syncer.dart';

final _log = Logger('UserPropertiesRepositoryImpl');

const _syncRetryDelay = Duration(minutes: 5);

//todo temporary fix
class const _UserIdProvider() implements UserIdProvider {
  @override
  Future<String> getUserId() async {
    return 'userId';
  }
}

class UserPropertiesRepositoryImpl implements UserPropertiesRepository {
  UserPropertiesRepositoryImpl({
    required UserPropertiesApiService apiService,
    UserPropertiesSyncer? syncer,
  }) {
    _syncer = syncer ?? UserPropertiesSyncer(apiService, _localStore);
  }

  final LocalKeyValueStore _localStore = LocalKeyValueStore(userIdProvider: _UserIdProvider());
  late UserPropertiesSyncer _syncer;

  Future<void>? _runningSync;
  var _syncRequested = false;
  Timer? _retryTimer;
  var _disposed = false;

  @override
  Future<void> saveUserProperty(LocalKeyValueStoreKeys key, Object? value) async {
    if (value == null) return deleteUserProperty(key);

    await _localStore.set(key, value);
    _triggerSync();
  }

  @override
  Future<void> deleteUserProperty(LocalKeyValueStoreKeys key) async {
    _log.fine('Deleting user property for key=$key');
    await _localStore.delete(key);
    await _syncer.deleteRemote(key);
  }

  @override
  Future<void> clearLocalUserProperties() async {
    _cancelRetry();
    await _localStore.clearUserProperties();
  }

  @override
  Future<void> syncUserProperties() {
    if (_disposed) return Future.value();

    _syncRequested = true;
    return _runningSync ??= _syncUntilSettled();
  }

  List<String> _convertToList(Object? value) => switch (value) {
    final List<dynamic> list => List<String>.from(list),
    final String json => List<String>.from(jsonDecode(json) as List),
    _ => throw StateError('Unexpected companyCodes value: $value'),
  };

  static DateTime? _parseDate(Object? value) => value is String ? DateTime.tryParse(value) : null;

  @override
  bool get showDecisiveGradient => _localStore.get(.showDecisiveGradient, true).value as bool;

  @override
  bool get showStationSignals => _localStore.get(.showStationSignals, true).value as bool;

  @override
  bool get showEctsConventionalSpeedSignals => _localStore.get(.showEctsConventionalSpeedSignals, true).value as bool;

  @override
  bool get showEctsExtendedSpeedSignals => _localStore.get(.showEctsExtendedSpeedSignals, true).value as bool;

  @override
  List<String> get companyCodes => _convertToList(_localStore.get(.companyCodes, <String>[]).value);

  @override
  TourSystem? get tourSystem => TourSystem.values.asNameMap()[_localStore.get(.tourSystem, null).value];

  @override
  String? get lastUsedCompanyCode => _localStore.get<String?>(.lastUsedCompanyCode, null).value as String?;

  @override
  bool get lastSettingsRequestSuccessful => _localStore.get<bool>(.lastSettingsRequestSuccessful, false).value as bool;

  @override
  DateTime? get lastSuccessfulSettingsTimestamp =>
      _parseDate(_localStore.get(.lastSuccessfulSettingsTimestamp, null).value);

  @override
  DateTime? get lastUserPropertiesSyncTimestamp =>
      _parseDate(_localStore.get(.lastUserPropertiesSyncTimestamp, null).value);

  @override
  Stream<LocalKeyValueStoreKeys?> get model => _localStore.model;

  Future<void> _syncUntilSettled() async {
    try {
      while (_syncRequested && !_disposed) {
        _syncRequested = false;
        await _syncer.sync();
      }
      _cancelRetry();
    } on Exception catch (e, s) {
      _log.warning('Syncing user properties failed. Scheduling retry.', e, s);
      _scheduleRetry();
      rethrow;
    } finally {
      _runningSync = null;
    }
  }

  void _triggerSync() {
    unawaited(syncUserProperties().catchError((_) {}, test: (e) => e is Exception));
  }

  void _scheduleRetry() {
    if (_disposed || _retryTimer != null) return;

    _retryTimer = Timer(_syncRetryDelay, () {
      _retryTimer = null;
      _triggerSync();
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelRetry();
  }
}
