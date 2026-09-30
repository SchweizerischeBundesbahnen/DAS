import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:user_properties/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_repository_impl.dart';
import 'package:user_properties/src/repository/user_properties_syncer.dart';

import 'user_properties_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPropertiesApiService>(),
  MockSpec<UserPropertiesSyncer>(),
  MockSpec<LocalKeyValueStore>(),
])
void main() {
  late MockUserPropertiesApiService apiService;
  late MockUserPropertiesSyncer syncer;
  late MockLocalKeyValueStore localStore;
  late UserPropertiesRepositoryImpl repository;

  const companyCodes = ['1285', '2185'];

  setUp(() {
    apiService = MockUserPropertiesApiService();
    syncer = MockUserPropertiesSyncer();
    localStore = MockLocalKeyValueStore();
    repository = UserPropertiesRepositoryImpl(
      apiService: apiService,
      syncer: syncer,
    );
  });

  UserPropertyModel p(String key, int ms) => UserPropertyModel(
    key: key,
    value: 'x',
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(ms),
  );

  test('neuere Seite gewinnt, fehlende Seite verliert immer', () {
    final plan = planSync(
      {'A': p('A', 100), 'B': p('B', 50), 'D': p('D', 70), 'E': p('E', 40)},
      {'A': p('A', 80), 'B': p('B', 90), 'C': p('C', 60), 'D': p('D', 70)},
    );

    expect(plan.push.map((e) => e.key), unorderedEquals(['A', 'E']));
    expect(plan.pull.map((e) => e.key), unorderedEquals(['B', 'C']));
  });

  test('saveUserProperty_whenValueIsNotNull_savesLocallyAndTriggersSync', () async {
    when(localStore.set(LocalKeyValueStoreKeys.companyCodes, companyCodes)).thenAnswer((_) => Future<void>.value());
    when(syncer.sync()).thenAnswer((_) => Future<void>.value());

    await repository.saveUserProperty(LocalKeyValueStoreKeys.companyCodes, companyCodes);

    await Future<void>.delayed(Duration.zero);

    verify(localStore.set(LocalKeyValueStoreKeys.companyCodes, companyCodes)).called(1);
    verify(syncer.sync()).called(1);
    verifyNever(syncer.deleteRemote(any));
    verifyNever(localStore.delete(any));
  });

  test('saveUserProperty_whenValueIsNull_deletesRemoteAndLocalValue', () async {
    when(syncer.deleteRemote(LocalKeyValueStoreKeys.lastUsedCompanyCode)).thenAnswer((_) => Future<void>.value());
    when(localStore.delete(LocalKeyValueStoreKeys.lastUsedCompanyCode)).thenAnswer((_) => Future<void>.value());

    await repository.saveUserProperty(LocalKeyValueStoreKeys.lastUsedCompanyCode, null);

    verify(syncer.deleteRemote(LocalKeyValueStoreKeys.lastUsedCompanyCode)).called(1);
    verify(localStore.delete(LocalKeyValueStoreKeys.lastUsedCompanyCode)).called(1);
    verifyNever(localStore.set(any, any));
    verifyNever(syncer.sync());
  });

  test('deleteUserProperty_deletesRemoteBeforeLocal', () async {
    when(syncer.deleteRemote(LocalKeyValueStoreKeys.lastUsedCompanyCode)).thenAnswer((_) => Future<void>.value());
    when(localStore.delete(LocalKeyValueStoreKeys.lastUsedCompanyCode)).thenAnswer((_) => Future<void>.value());

    await repository.deleteUserProperty(LocalKeyValueStoreKeys.lastUsedCompanyCode);

    verifyInOrder([
      syncer.deleteRemote(LocalKeyValueStoreKeys.lastUsedCompanyCode),
      localStore.delete(LocalKeyValueStoreKeys.lastUsedCompanyCode),
    ]);
  });

  test('syncUserProperties_whenCalledMultipleTimesWhileRunning_triggersSyncOnce', () async {
    final completer = Completer<void>();
    when(syncer.sync()).thenAnswer((_) => completer.future);

    final first = repository.syncUserProperties();
    final second = repository.syncUserProperties();

    expect(first, same(second));
    verify(syncer.sync()).called(1);

    completer.complete();
    await Future.wait([first, second]);

    verify(syncer.sync()).called(1);
  });

  test('syncUserProperties_whenSyncFails_schedulesRetryAndRetriesAfterFiveMinutes', () {
    fakeAsync((async) {
      var firstCall = true;
      when(syncer.sync()).thenAnswer((_) {
        if (firstCall) {
          firstCall = false;
          return Future<void>.error(Exception('boom'));
        }
        return Future<void>.value();
      });

      repository.syncUserProperties().catchError((_) {});
      async.flushMicrotasks();

      verify(syncer.sync()).called(1);

      async.elapse(const Duration(minutes: 5, milliseconds: 1));
      async.flushMicrotasks();

      verify(syncer.sync()).called(1);
    });
  });

  test('clearLocalUserProperties_cancelsScheduledRetry', () {
    fakeAsync((async) {
      var firstCall = true;
      when(syncer.sync()).thenAnswer((_) {
        if (firstCall) {
          firstCall = false;
          return Future<void>.error(Exception('boom'));
        }
        return Future<void>.value();
      });
      when(localStore.clearUserProperties()).thenAnswer((_) => Future<void>.value());

      repository.syncUserProperties().catchError((_) {});
      async.flushMicrotasks();

      repository.clearLocalUserProperties();
      async.flushMicrotasks();

      verify(localStore.clearUserProperties()).called(1);

      async.elapse(const Duration(minutes: 5, milliseconds: 1));
      async.flushMicrotasks();

      verify(syncer.sync()).called(1);
    });
  });

  test('planSync_whenVersionsDiffer_choosesNewerSide', () {
    final plan = planSync(
      {'A': p('A', 100), 'B': p('B', 50), 'D': p('D', 70), 'E': p('E', 40)},
      {'A': p('A', 80), 'B': p('B', 90), 'C': p('C', 60), 'D': p('D', 70)},
    );

    expect(plan.push.map((e) => e.key), unorderedEquals(['A', 'E']));
    expect(plan.pull.map((e) => e.key), unorderedEquals(['B', 'C']));
  });
}
