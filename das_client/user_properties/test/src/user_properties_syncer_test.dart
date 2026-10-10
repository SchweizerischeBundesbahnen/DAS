import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_x/component.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:user_properties/component.dart';
import 'package:user_properties/src/api/dto/user_properties_response_dto.dart';
import 'package:user_properties/src/api/dto/user_property_dto.dart';
import 'package:user_properties/src/api/endpoint/user_properties.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_syncer.dart';

import 'user_properties_syncer_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPropertiesApiService>(),
  MockSpec<LocalKeyValueStore>(),
  MockSpec<UserPropertiesRequest>(),
  MockSpec<SaveUserPropertyRequest>(),
  MockSpec<DeleteUserPropertyRequest>(),
])
void main() {
  late MockUserPropertiesApiService mockApiService;
  late MockLocalKeyValueStore mockLocalStore;
  late MockUserPropertiesRequest mockListRequest;
  late UserPropertiesSyncer testee;
  late MockDeleteUserPropertyRequest mockDeleteRequest;

  final stationSignals = LocalKeyValueStoreKeys.showStationSignals.name;
  final decisiveGradient = LocalKeyValueStoreKeys.showDecisiveGradient.name;

  UserPropertyModel model(String key, int ms, {Object? value = true}) => UserPropertyModel(
    key: key,
    value: value,
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
  );

  UserPropertyDto dto(String key, int ms, {Object? value = true}) => UserPropertyDto(
    key: key,
    value: value,
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
  );

  void givenRemote(List<UserPropertyDto> remote) {
    when(mockListRequest.call()).thenAnswer(
      (_) async => UserPropertiesResponse(
        headers: const {},
        body: UserPropertiesResponseDto(data: remote),
      ),
    );
  }

  void givenLocal(List<UserPropertyModel> local) {
    when(mockLocalStore.getAllLocalUserProperties()).thenAnswer((_) async => local);
  }

  MockSaveUserPropertyRequest givenSaveRequest(String key, {bool succeeds = true}) {
    final request = MockSaveUserPropertyRequest();
    when(mockApiService.saveUserProperty(key, any)).thenReturn(request);
    when(request.call()).thenAnswer(
      (_) async => succeeds
          ? UserPropertiesResponse(
              headers: const {},
              body: UserPropertiesResponseDto(data: const []),
            )
          : throw Exception('push failed for $key'),
    );
    return request;
  }

  setUp(() {
    mockApiService = MockUserPropertiesApiService();
    mockLocalStore = MockLocalKeyValueStore();
    mockListRequest = MockUserPropertiesRequest();

    when(mockApiService.userProperties()).thenReturn(mockListRequest);
    when(mockLocalStore.ready).thenAnswer((_) async {});
    when(mockLocalStore.put(any)).thenAnswer((_) async {});
    when(mockLocalStore.setLastUserPropertiesSyncTimestamp(any)).thenAnswer((_) async {});

    givenRemote(const []);
    givenLocal(const []);

    testee = UserPropertiesSyncer(mockApiService, mockLocalStore);
  });

  test('sync_whenRemoteIsNewer_thenPullsRemoteValueIntoLocalStore', () async {
    // GIVEN
    givenLocal([model(stationSignals, 100, value: true)]);
    givenRemote([dto(stationSignals, 200, value: false)]);

    // WHEN
    await testee.sync();

    // THEN
    final pulled = verify(mockLocalStore.put(captureAny)).captured.single as UserPropertyModel;
    expect(pulled.key, stationSignals);
    expect(pulled.value, false);
    verifyNever(mockApiService.saveUserProperty(any, any));
  });

  test('sync_whenLocalIsNewer_thenPushesLocalValueToRemote', () async {
    // GIVEN
    givenSaveRequest(stationSignals);
    givenLocal([model(stationSignals, 300, value: false)]);
    givenRemote([dto(stationSignals, 100, value: true)]);

    // WHEN
    await testee.sync();

    // THEN
    verify(mockApiService.saveUserProperty(stationSignals, false)).called(1);
    verifyNever(mockLocalStore.put(any));
  });

  test('sync_whenTimestampsAreEqual_thenDoesNothingExceptStoringUtcSyncTimestamp', () async {
    // GIVEN
    final now = DateTime.utc(2026, 10, 8, 12, 30);
    givenLocal([model(stationSignals, 100)]);
    givenRemote([dto(stationSignals, 100)]);

    // WHEN
    await withClock(Clock.fixed(now), () => testee.sync());

    // THEN
    verifyNever(mockLocalStore.put(any));
    verifyNever(mockApiService.saveUserProperty(any, any));
    verify(mockLocalStore.setLastUserPropertiesSyncTimestamp(now)).called(1);
  });

  test('sync_whenRemoteHasUnknownOrLocalOnlyKeys_thenIgnoresThem', () async {
    // GIVEN
    givenRemote([
      dto('someFutureProperty', 100),
      dto(LocalKeyValueStoreKeys.lastSettingsRequestSuccessful.name, 100),
    ]);

    // WHEN
    await testee.sync();

    // THEN
    verifyNever(mockLocalStore.put(any));
  });

  test('sync_whenOnePushFails_thenThrowsPartialFailureStillPushesOthersAndSkipsSyncTimestamp', () async {
    // GIVEN
    givenSaveRequest(stationSignals, succeeds: false);
    final okRequest = givenSaveRequest(decisiveGradient);
    givenLocal([model(stationSignals, 100, value: false), model(decisiveGradient, 100, value: false)]);

    // WHEN
    final result = testee.sync();

    // THEN
    await expectLater(
      result,
      throwsA(
        isA<SyncPartiallyFailedException>().having((e) => e.failedKeys, 'failedKeys', [stationSignals]),
      ),
    );
    verify(okRequest.call()).called(1);
    verifyNever(mockLocalStore.setLastUserPropertiesSyncTimestamp(any));
  });

  HttpException httpException(int statusCode) => HttpException(
    Request('DELETE', Uri.https('example.com', 'driver/v1/user-properties/key')),
    Response('', statusCode),
  );

  setUp(() {
    mockDeleteRequest = MockDeleteUserPropertyRequest();
    when(mockApiService.deleteUserProperty(any)).thenReturn(mockDeleteRequest);
  });

  test('deleteRemote_whenPropertyDoesNotExistRemotely_thenTreatsNotFoundAsSuccess', () async {
    // GIVEN
    when(mockDeleteRequest.call()).thenAnswer((_) async => throw httpException(404));

    // THEN
    await expectLater(testee.deleteRemote(LocalKeyValueStoreKeys.tourSystem), completes);
  });

  test('deleteRemote_whenServerErrorOccurs_thenRethrows', () async {
    // GIVEN
    when(mockDeleteRequest.call()).thenAnswer((_) async => throw httpException(500));

    // THEN
    await expectLater(
      testee.deleteRemote(LocalKeyValueStoreKeys.tourSystem),
      throwsA(isA<HttpException>().having((e) => e.statusCode, 'statusCode', 500)),
    );
  });
}
