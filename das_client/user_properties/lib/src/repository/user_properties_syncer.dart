import 'dart:io' show HttpStatus;

import 'package:clock/clock.dart';
import 'package:http_x/component.dart';
import 'package:logging/logging.dart';
import 'package:user_properties/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';

final _log = Logger('UserPropertiesSyncer');

typedef SyncPlan = ({List<UserPropertyModel> pull, List<UserPropertyModel> push});

SyncPlan planSync(
  Map<String, UserPropertyModel> local,
  Map<String, UserPropertyModel> remote,
) {
  final pull = <UserPropertyModel>[];
  final push = <UserPropertyModel>[];

  for (final key in {...local.keys, ...remote.keys}) {
    final l = local[key], r = remote[key];
    final diff = _version(l).compareTo(_version(r));
    if (diff > 0) push.add(l!);
    if (diff < 0) pull.add(r!);
  }

  return (pull: pull, push: push);
}

int _version(UserPropertyModel? p) => p == null ? -1 : p.lastUpdated?.millisecondsSinceEpoch ?? 0;

Map<String, UserPropertyModel> _byKey(Iterable<UserPropertyModel> props) => {for (final p in props) p.key: p};

String _describe(Map<String, UserPropertyModel> props) =>
    props.values.map((p) => '${p.key}@${p.lastUpdated?.toIso8601String()}').join(', ');

class SyncPartiallyFailedException implements Exception {
  const SyncPartiallyFailedException(this.failedKeys);

  final List<String> failedKeys;

  @override
  String toString() => 'SyncPartiallyFailedException(failedKeys: $failedKeys)';
}

class UserPropertiesSyncer {
  UserPropertiesSyncer(this._apiService, this._localStore);

  final UserPropertiesApiService _apiService;
  final LocalKeyValueStore _localStore;

  Future<void> sync() async {
    await _localStore.ready;

    final remote = _byKey(await _fetchRemote());
    final local = _byKey(await _localStore.getAllLocalUserProperties());
    _log.fine('Remote: ${_describe(remote)}');
    _log.fine('Local:  ${_describe(local)}');

    final plan = planSync(local, remote);
    _log.info('Sync plan: pull=${plan.pull.length}, push=${plan.push.length}');

    for (final p in plan.pull) {
      await _localStore.put(p);
    }

    final pushed = await Future.wait(plan.push.map(_tryPush));
    final failedKeys = [
      for (final (i, ok) in pushed.indexed)
        if (!ok) plan.push[i].key,
    ];

    if (failedKeys.isNotEmpty) throw SyncPartiallyFailedException(failedKeys);

    await _localStore.setLastUserPropertiesSyncTimestamp(clock.now().toUtc());
  }

  Future<void> deleteRemote(LocalKeyValueStoreKeys key) async {
    try {
      await _apiService.deleteUserProperty(key.name).call();
    } on HttpException catch (e) {
      if (e.statusCode == HttpStatus.notFound) return;
      rethrow;
    }
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

  Future<List<UserPropertyModel>> _fetchRemote() async {
    final response = await _apiService.userProperties().call();
    return response.body.data
        .map((dto) => dto.toModel())
        .where((p) => LocalKeyValueStore.syncedKeyNames.contains(p.key))
        .toList(growable: false);
  }
}
