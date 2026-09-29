import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:http_x/component.dart';
import 'package:logging/logging.dart';
import 'package:user_properties/src/api/model/user_property_model.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_repository.dart';
import 'package:user_properties/src/repository/user_properties_syncer.dart';
import 'package:user_properties/src/repository/local_key_value_store.dart';

final _log = Logger('UserPropertiesRepositoryImpl');

const _syncRetryDelay = Duration(minutes: 5);

class UserPropertiesRepositoryImpl implements UserPropertiesRepository {
  UserPropertiesRepositoryImpl({
    required UserPropertiesApiService apiService,
    required LocalKeyValueStore localStore,
    UserPropertiesSyncer? syncer,
  }) : _apiService = apiService,
       _localStore = localStore,
       _syncer = syncer ?? UserPropertiesSyncer(apiService, localStore);

  final UserPropertiesApiService _apiService;
  final LocalKeyValueStore _localStore;
  final UserPropertiesSyncer _syncer;

  Future<List<UserPropertyModel>>? _pendingSync;
  Timer? _retrySyncTimer;
  var _disposed = false;

  @override
  Future<void> clearLocalUserProperties() async {
    await _localStore.clearUserProperties();
    _cancelScheduledRetry();
  }

  @override
  Future<void> deleteUserProperty(LocalKeyValueStoreKeys key) async {
    _log.fine('Deleting user property for key=$key');
    try {
      await _apiService.deleteUserProperty(key.name).call();
      await _localStore.delete(key);
      _log.fine('User property deleted from both backend and local store: $key');
    } on Exception catch (e, s) {
      _log.severe('Failed to delete user property for key=$key', e, s);
      rethrow;
    }
  }

  @override
  Future<List<UserPropertyModel>> syncUserProperties() {
    return _pendingSync ??= _syncUserProperties().whenComplete(() => _pendingSync = null);
  }

  Future<List<UserPropertyModel>> _syncUserProperties() async {
    _log.fine('Syncing all user properties');

    try {
      final result = await _syncer.sync();
      _cancelScheduledRetry();
      return result;
    } on Exception catch (e, s) {
      _log.warning('Syncing user properties failed. Scheduling retry.', e, s);
      _scheduleRetry();
      rethrow;
    }
  }

  void _scheduleRetry() {
    if (_disposed || _retrySyncTimer != null) return;

    _retrySyncTimer = Timer(_syncRetryDelay, () {
      _retrySyncTimer = null;
      unawaited(
        syncUserProperties().catchError((error, stackTrace) {
          _log.warning('Scheduled retry for user properties sync failed.', error, stackTrace);
          return <UserPropertyModel>[];
        }),
      );
    });
  }

  void _cancelScheduledRetry() {
    _retrySyncTimer?.cancel();
    _retrySyncTimer = null;
  }

  @override
  Future<List<UserPropertyModel>> getAllUserProperties() => syncUserProperties();

  @override
  Future<UserPropertyModel?> getUserProperty(LocalKeyValueStoreKeys key) async {
    _log.fine('Loading user property for key=$key from backend');

    try {
      final response = await _apiService.userProperty(key.name).call();
      if (response.body.data.isEmpty) {
        _log.fine('No user property found for key=$key on backend');
        return null;
      }

      final model = response.body.data.first.toModel();
      await _localStore.put(model);

      _log.fine('Synced user property to local store: $key');
      return model;
    } on HttpException catch (e) {
      if (e.statusCode == HttpStatus.notFound) {
        _log.fine('No user property found for key=$key');
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<UserPropertyModel> saveUserProperty(LocalKeyValueStoreKeys key, Object? value) async {
    _log.fine('Saving user property for key=$key with value=$value');

    final model = UserPropertyModel(key: key.name, value: value, lastUpdated: clock.now().toUtc());
    await _localStore.put(model);

    if (!await _tryPush(model)) {
      _log.warning('Failed to push user property for key=$key. Keeping local value and scheduling retry.');
      _scheduleRetry();
    } else {
      _log.fine('User property saved and pushed: $key');
    }

    return model;
  }

  Future<bool> _tryPush(UserPropertyModel p) async {
    try {
      await _apiService.saveUserProperty(p.key, p.value).call();
      return true;
    } on Exception catch (e, s) {
      _log.warning('Push failed for key=${p.key}', e, s);
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelScheduledRetry();
  }
}
