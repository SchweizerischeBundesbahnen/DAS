import 'dart:io' show HttpStatus;

import 'package:clock/clock.dart';
import 'package:http_x/component.dart';
import 'package:logging/logging.dart';
import 'package:user_properties/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';

final _log = Logger('UserPropertiesSyncer');

typedef SyncPlan = ({List<UserPropertyModel> pull, List<UserPropertyModel> push});

/// Vergleicht Local und Remote pro Key (Last-Write-Wins).
/// Neuere Seite gewinnt, fehlende Seite verliert immer, Gleichstand = nichts tun.
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

/// Fehlende Property = -1 (älter als alles).
/// Property ohne lastUpdated = 0 (1.1.1970).
int _version(UserPropertyModel? p) => p == null ? -1 : p.lastUpdated?.millisecondsSinceEpoch ?? 0;

Map<String, UserPropertyModel> _byKey(Iterable<UserPropertyModel> props) => {for (final p in props) p.key: p};

/// Wird geworfen, wenn mindestens ein Push im Abgleich fehlgeschlagen ist.
class SyncPartiallyFailedException implements Exception {
  const SyncPartiallyFailedException(this.failedKeys);

  final List<String> failedKeys;

  @override
  String toString() => 'SyncPartiallyFailedException(failedKeys: $failedKeys)';
}

/// Einziger Ort, der mit dem User-Properties-Backend spricht.
/// Kennt weder Retry-Timer noch Single-Flight — das ist Sache des Repositories.
class UserPropertiesSyncer {
  UserPropertiesSyncer(this._apiService, this._localStore);

  final UserPropertiesApiService _apiService;
  final LocalKeyValueStore _localStore;

  /// Vollständiger LWW-Abgleich.
  /// Wirft [SyncPartiallyFailedException], wenn einzelne Pushes scheitern.
  Future<void> sync() async {
    final remote = _byKey(await _fetchRemote());
    final local = _byKey(_localStore.getAllLocalUserProperties());
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

  /// Löscht eine Property im Backend.
  /// 404 zählt als Erfolg: Das Ziel "nicht vorhanden" ist erreicht (Idempotenz).
  Future<void> deleteRemote(LocalKeyValueStoreKeys key) async {
    try {
      await _apiService.deleteUserProperty(key.name).call();
    } on HttpException catch (e) {
      if (e.statusCode == HttpStatus.notFound) return;
      rethrow;
    }
  }

  /// Wirft nie: Fehler werden als `false` zurückgegeben,
  /// damit Future.wait alle Pushes zu Ende laufen lässt.
  Future<bool> _tryPush(UserPropertyModel p) async {
    try {
      await _apiService.saveUserProperty(p.key, p.value).call();
      return true;
    } on Exception catch (e, s) {
      _log.warning('Push failed for key=${p.key}', e, s);
      return false;
    }
  }

  /// Keys, die diese App-Version nicht kennt, werden ignoriert (Forward Compatibility).
  /// Sonst würden sie bei jedem Sync erneut gepullt.
  Future<List<UserPropertyModel>> _fetchRemote() async {
    final response = await _apiService.userProperties().call();
    return response.body.data
        .map((dto) => dto.toModel())
        .where((p) => LocalKeyValueStore.syncedKeyNames.contains(p.key))
        .toList(growable: false);
  }
}
