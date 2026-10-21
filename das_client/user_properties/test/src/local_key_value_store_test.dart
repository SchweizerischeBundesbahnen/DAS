import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_properties/component.dart';

class _FakeUserIdProvider implements UserIdProviderProperties {
  _FakeUserIdProvider(this.userId);

  final String userId;

  @override
  Future<String> call() async => userId;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalKeyValueStore testee;

  String prefsKey(LocalKeyValueStoreKeys key, {String user = 'u12345'}) => '$user-${key.name}';

  String storedJson(LocalKeyValueStoreKeys key, Object? value) =>
      jsonEncode({'key': key.name, 'value': value, 'lastUpdated': null});

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testee = LocalKeyValueStore(userIdProvider: _FakeUserIdProvider('u12345'));
  });

  tearDown(() {
    testee.dispose();
  });

  test('set_whenCalled_thenPersistsUnderUserPrefixedKeyWithUtcTimestamp', () async {
    // GIVEN
    final now = DateTime.utc(2026, 10, 8, 12, 30);

    // WHEN
    await withClock(Clock.fixed(now), () => testee.set(LocalKeyValueStoreKeys.showDecisiveGradient, false));

    // THEN
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {prefsKey(LocalKeyValueStoreKeys.showDecisiveGradient)});
    final result = testee.get(LocalKeyValueStoreKeys.showDecisiveGradient, true);
    expect(result.value, false);
    expect(result.lastUpdated, now);
  });

  test('get_whenUserIdNotYetResolved_thenReturnsDefaultUntilResolved', () async {
    // GIVEN
    SharedPreferences.setMockInitialValues({
      prefsKey(LocalKeyValueStoreKeys.showStationSignals): storedJson(
        LocalKeyValueStoreKeys.showStationSignals,
        false,
      ),
    });
    testee.dispose();
    testee = LocalKeyValueStore(userIdProvider: _FakeUserIdProvider('u12345'));
    await testee.ready;

    // WHEN / THEN
    expect(testee.get(LocalKeyValueStoreKeys.showStationSignals, true).value, true);

    await testee.getAllLocalUserProperties();
    expect(testee.get(LocalKeyValueStoreKeys.showStationSignals, true).value, false);
  });

  test('clearUserProperties_whenAnotherUserHasValues_thenKeepsOtherUsersValues', () async {
    // GIVEN
    final otherUserStore = LocalKeyValueStore(userIdProvider: _FakeUserIdProvider('u2'));
    await otherUserStore.set(LocalKeyValueStoreKeys.showStationSignals, false);
    expect(await testee.getAllLocalUserProperties(), isEmpty);
    await testee.set(LocalKeyValueStoreKeys.showStationSignals, true);

    // WHEN
    await testee.clearUserProperties();

    // THEN
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {prefsKey(LocalKeyValueStoreKeys.showStationSignals, user: 'u2')});
    otherUserStore.dispose();
  });

  test('getAllLocalUserProperties_whenSyncedAndLocalOnlyKeysStored_thenReturnsOnlySyncedKeys', () async {
    // GIVEN
    await testee.set(LocalKeyValueStoreKeys.showStationSignals, false);
    await testee.set(LocalKeyValueStoreKeys.companyCodes, ['1285']);
    await testee.set(LocalKeyValueStoreKeys.lastSettingsRequestSuccessful, true);
    await testee.set(LocalKeyValueStoreKeys.lastUserPropertiesSyncTimestamp, '2026-10-08T12:00:00.000Z');

    // WHEN
    final result = await testee.getAllLocalUserProperties();

    // THEN
    expect(
      result.map((it) => it.key),
      unorderedEquals([LocalKeyValueStoreKeys.showStationSignals.name, LocalKeyValueStoreKeys.companyCodes.name]),
    );
  });

  test('getAllLocalUserProperties_whenOneEntryIsCorrupt_thenSkipsOnlyThatEntry', () async {
    // GIVEN
    SharedPreferences.setMockInitialValues({
      prefsKey(LocalKeyValueStoreKeys.showStationSignals): 'corrupt',
      prefsKey(LocalKeyValueStoreKeys.showDecisiveGradient): storedJson(
        LocalKeyValueStoreKeys.showDecisiveGradient,
        false,
      ),
    });
    testee.dispose();
    testee = LocalKeyValueStore(userIdProvider: _FakeUserIdProvider('u12345'));

    // WHEN
    final result = await testee.getAllLocalUserProperties();

    // THEN
    expect(result.map((it) => it.key), [LocalKeyValueStoreKeys.showDecisiveGradient.name]);
  });
}
