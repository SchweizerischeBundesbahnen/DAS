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
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserPropertiesSyncer syncer;
  late UserPropertiesRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    syncer = MockUserPropertiesSyncer();
    when(syncer.sync()).thenAnswer((_) async {});
    when(syncer.deleteRemote(any)).thenAnswer((_) async {});
    repository = UserPropertiesRepositoryImpl(
      apiService: MockUserPropertiesApiService(),
      userIdProvider: _FakeUserIdProvider(),
      syncer: syncer,
    );
  });

  tearDown(() {
    repository.dispose();
  });

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

  test('saveUserProperty_whenValueIsNull_thenDeletesRemoteAndLocal', () async {
    // GIVEN
    await repository.saveUserProperty(LocalKeyValueStoreKeys.lastUsedCompanyCode, '1285');
    await Future<void>.delayed(Duration.zero);

    // WHEN
    await repository.saveUserProperty(LocalKeyValueStoreKeys.lastUsedCompanyCode, null);

    // THEN
    verify(syncer.deleteRemote(LocalKeyValueStoreKeys.lastUsedCompanyCode)).called(1);
    expect(repository.lastUsedCompanyCode, isNull);
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

  test('tourSystem_whenStoredNameIsUnknown_thenReturnsNull', () async {
    // GIVEN
    await repository.saveUserProperty(LocalKeyValueStoreKeys.tourSystem, 'someFutureTourSystem');

    // THEN
    expect(repository.tourSystem, isNull);
  });
}
