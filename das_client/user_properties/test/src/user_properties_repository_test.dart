import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_properties/component.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_repository_impl.dart';
import 'package:user_properties/src/repository/user_properties_syncer.dart';

import 'user_properties_repository_test.mocks.dart';

class _FakeUserIdProvider implements UserIdProviderProperties {
  @override
  Future<String> call() async => 'u12345';
}

@GenerateNiceMocks([
  MockSpec<UserPropertiesApiService>(),
  MockSpec<UserPropertiesSyncer>(),
  MockSpec<LocalKeyValueStore>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserPropertiesSyncer syncer;
  late UserPropertiesRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    syncer = MockUserPropertiesSyncer();
    when(syncer.sync()).thenAnswer((_) async {});
    repository = UserPropertiesRepositoryImpl(
      apiService: MockUserPropertiesApiService(),
      userIdProvider: _FakeUserIdProvider(),
      syncer: syncer,
    );
    await Future<void>.delayed(Duration.zero);
    clearInteractions(syncer);
  });

  tearDown(() async => repository.dispose());

  test('saveUserProperty_whenKeyIsSynced_thenSavesLocallyAndTriggersSync', () async {
    // WHEN
    await repository.saveUserProperty(LocalKeyValueStoreKeys.showStationSignals, false);
    await Future<void>.delayed(Duration.zero);

    // THEN
    expect(repository.showStationSignals, false);
    verify(syncer.sync()).called(1);
  });

  test('saveUserProperty_whenKeyIsLocalOnly_thenSavesLocallyWithoutTriggeringSync', () async {
    // WHEN
    await repository.saveUserProperty(LocalKeyValueStoreKeys.lastSettingsRequestSuccessful, true);
    await Future<void>.delayed(Duration.zero);

    // THEN
    expect(repository.lastSettingsRequestSuccessful, true);
    verifyNever(syncer.sync());
  });

  test('syncUserProperties_whenRequestedWhileRunning_thenSharesFutureAndRunsAnotherPass', () async {
    // GIVEN
    final completer = Completer<void>();
    when(syncer.sync()).thenAnswer((_) => completer.future);

    // WHEN
    final first = repository.syncUserProperties();
    final second = repository.syncUserProperties();
    completer.complete();
    await Future.wait([first, second]);

    // THEN
    expect(first, same(second));
    verify(syncer.sync()).called(2);
  });

  test('syncUserProperties_whenSyncFails_thenRetriesAfterFiveMinutes', () {
    fakeAsync((async) {
      // GIVEN
      var calls = 0;
      when(syncer.sync()).thenAnswer((_) {
        calls++;
        return calls == 1 ? Future<void>.error(Exception('boom')) : Future<void>.value();
      });

      // WHEN
      repository.syncUserProperties().catchError((_) {});
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5, milliseconds: 1));
      async.flushMicrotasks();

      // THEN
      expect(calls, 2);
    });
  });

  test('dispose_whenRetryIsScheduled_thenCancelsRetry', () {
    fakeAsync((async) {
      // GIVEN
      var calls = 0;
      when(syncer.sync()).thenAnswer((_) {
        calls++;
        return Future<void>.error(Exception('boom'));
      });
      repository.syncUserProperties().catchError((_) {});
      async.flushMicrotasks();

      // WHEN
      repository.dispose();
      async.elapse(const Duration(minutes: 10));
      async.flushMicrotasks();

      // THEN
      expect(calls, 1);
    });
  });

  test('clearLocalUserProperties_whenSyncIsRunning_thenWaitsBeforeClearing', () async {
    // GIVEN
    final store = LocalKeyValueStore(userIdProvider: _FakeUserIdProvider());
    await repository.dispose();
    final syncStarted = Completer<void>();
    final finishSync = Completer<void>();
    when(syncer.sync()).thenAnswer((_) async {
      syncStarted.complete();
      await finishSync.future;
      await store.set(LocalKeyValueStoreKeys.showStationSignals, false);
      await store.setLastUserPropertiesSyncTimestamp(DateTime.utc(2026));
    });
    repository = UserPropertiesRepositoryImpl(
      apiService: MockUserPropertiesApiService(),
      userIdProvider: _FakeUserIdProvider(),
      localStore: store,
      syncer: syncer,
    );
    final sync = repository.syncUserProperties();
    await syncStarted.future;

    // WHEN
    var cleared = false;
    final clear = repository.clearLocalUserProperties().then((_) => cleared = true);
    await Future<void>.delayed(Duration.zero);
    expect(cleared, false);
    await expectLater(repository.syncUserProperties(), throwsStateError);
    await expectLater(repository.saveUserProperty(LocalKeyValueStoreKeys.tourSystem, 'tip'), throwsStateError);
    finishSync.complete();
    await sync;
    await clear;

    // THEN
    expect(repository.showStationSignals, true);
    expect(repository.lastUserPropertiesSyncTimestamp, isNull);
    verify(syncer.sync()).called(1);
  });

  test('clearLocalUserProperties_whenSaveIsRunning_thenWaitsBeforeClearing', () async {
    // GIVEN
    final store = MockLocalKeyValueStore();
    final saveStarted = Completer<void>();
    final finishSave = Completer<void>();
    when(store.set(any, any)).thenAnswer((_) {
      saveStarted.complete();
      return finishSave.future;
    });
    when(store.clearUserProperties()).thenAnswer((_) async {});
    await repository.dispose();
    repository = UserPropertiesRepositoryImpl(
      apiService: MockUserPropertiesApiService(),
      userIdProvider: _FakeUserIdProvider(),
      localStore: store,
      syncer: syncer,
    );
    clearInteractions(syncer);
    final save = repository.saveUserProperty(LocalKeyValueStoreKeys.showStationSignals, false);
    await saveStarted.future;

    // WHEN
    final clear = repository.clearLocalUserProperties();
    await Future<void>.delayed(Duration.zero);
    verifyNever(store.clearUserProperties());
    finishSave.complete();
    await save;
    await clear;

    // THEN
    verify(store.clearUserProperties()).called(1);
    verifyNever(syncer.sync());
  });

  test('clearLocalUserProperties_whenRunningSyncFails_thenStillClears', () async {
    // GIVEN
    final syncCompleter = Completer<void>();
    when(syncer.sync()).thenAnswer((_) => syncCompleter.future);
    final sync = repository.syncUserProperties();
    final failedSync = expectLater(sync, throwsException);

    // WHEN
    final clear = repository.clearLocalUserProperties();
    syncCompleter.completeError(Exception('sync failed'));
    await failedSync;
    await clear;

    // THEN
    expect(repository.lastUserPropertiesSyncTimestamp, isNull);
    await expectLater(repository.syncUserProperties(), throwsStateError);
  });

  test('tourSystem_whenStoredNameIsUnknown_thenReturnsNull', () async {
    // GIVEN
    await repository.saveUserProperty(LocalKeyValueStoreKeys.tourSystem, 'someFutureTourSystem');

    // THEN
    expect(repository.tourSystem, isNull);
  });
}
