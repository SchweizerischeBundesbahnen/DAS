import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:settings/component.dart';
import 'package:settings/src/api/dto/app_version_expiration_dto.dart';
import 'package:settings/src/api/dto/logging_setting_dto.dart';
import 'package:settings/src/api/dto/preload_dto.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';
import 'package:settings/src/api/dto/settings_dto.dart';
import 'package:settings/src/api/dto/settings_response_dto.dart';
import 'package:settings/src/api/endpoint/settings.dart';
import 'package:settings/src/api/settings_api_service.dart';
import 'package:settings/src/data/local/settings_database_service.dart';
import 'package:settings/src/repository/settings_repository_impl.dart';

import 'settings_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SettingsDatabaseService>(),
  MockSpec<SettingsApiService>(),
  MockSpec<SettingsRequest>(),
  MockSpec<Callbacks>(),
])
void main() {
  late SettingsRepository testee;
  late SettingsDatabaseService settingsDatabaseService;
  late MockCallbacks mockCallbacks;
  late SettingsApiService apiService;
  late FakeAsync testAsync;
  late SettingsRequest mockSettingsRequest;

  SettingsResponse buildSettingsResponse({
    String loggingUrl = 'https://log.example.com',
    String loggingToken = 'token123',
    String bucketUrl = 'https://bucket.example.com',
    String accessKey = 'accessKey',
    String accessSecret = 'accessSecret',
    List<RuFeatureDto> ruFeatures = const [],
    bool appVersionExpired = false,
    DateTime? appVersionExpiryDate,
  }) {
    return SettingsResponse(
      headers: {},
      body: SettingsResponseDto(
        data: [
          SettingsDto(
            logging: LoggingSettingDto(url: loggingUrl, token: loggingToken),
            ruFeatures: ruFeatures,
            preload: PreloadDto(bucketUrl: bucketUrl, accessKey: accessKey, accessSecret: accessSecret),
            currentAppVersion: AppVersionExpirationDto(expired: appVersionExpired, expiryDate: appVersionExpiryDate),
          ),
        ],
      ),
    );
  }

  setUp(() {
    settingsDatabaseService = MockSettingsDatabaseService();
    mockSettingsRequest = MockSettingsRequest();
    apiService = MockSettingsApiService();
    mockCallbacks = MockCallbacks();
    when(apiService.settings).thenReturn(mockSettingsRequest);
  });

  tearDown(() {
    reset(mockSettingsRequest);
  });

  Future<void> initTestee({bool withAwsCallback = true}) async {
    fakeAsync((fakeAsync) {
      testAsync = fakeAsync;
      testee = SettingsRepositoryImpl(
        apiService: apiService,
        databaseService: settingsDatabaseService,
        onAwsCredentialsChanged: withAwsCallback ? mockCallbacks.awsCredentialsChanged : null,
      );
      fakeAsync.flushMicrotasks();
    });
  }

  test('whenInitialized_triesLoadingSettingsAndSilentsHttpException', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();

    // EXPECT
    verify(apiService.settings).called(1);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenInitialized_RetriesAfterErrorWithDelay', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();
    testAsync.elapse(SettingsRepositoryImpl.retryDelay + Duration(milliseconds: 100));

    // EXPECT
    verify(apiService.settings).called(2);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenEmptyResponse_RetriesWithDelay', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        SettingsResponse(
          headers: {},
          body: SettingsResponseDto(data: List.empty()),
        ),
      ),
    );

    // ACT
    await initTestee();
    testAsync.elapse(SettingsRepositoryImpl.retryDelay + Duration(milliseconds: 100));

    // EXPECT
    verify(apiService.settings).called(2);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenInitialized_MultipleErrorsRetryMultipleTimes', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();
    testAsync.elapse((SettingsRepositoryImpl.retryDelay * 3) + Duration(milliseconds: 100));

    // EXPECT
    verify(apiService.settings).called(4);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenSuccessAfterError_stopsRetrying', () async {
    // ARRANGE
    var callCount = 0;
    when(apiService.settings).thenAnswer((_) {
      callCount++;
      if (callCount == 1) throw HttpException('Exception');
      return mockSettingsRequest;
    });
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // ACT
    await initTestee();
    testAsync.elapse(SettingsRepositoryImpl.retryDelay * 2 + Duration(milliseconds: 100));

    // EXPECT
    verify(apiService.settings).called(2);
  });

  test('whenSettingsLoadedSuccessfully_savesRuFeaturesToDatabase', () async {
    // ARRANGE
    final ruFeatures = [
      RuFeatureDto(companyCodeRics: 'SBB', key: RuFeatureKeys.warnapp.key, enabled: true),
    ];
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(ruFeatures: ruFeatures)));

    // ACT
    await initTestee();

    // EXPECT
    verify(settingsDatabaseService.saveRuFeatures(ruFeatures)).called(1);
  });

  test('whenSettingsLoadedSuccessfully_callsAwsCredentialsChanged', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        buildSettingsResponse(bucketUrl: 'https://new-bucket.com', accessKey: 'key', accessSecret: 'secret'),
      ),
    );

    // ACT
    await initTestee();

    // EXPECT
    verify(mockCallbacks.awsCredentialsChanged(any)).called(1);
  });

  test('whenSettingsLoadedSuccessfully_awsCredentialsChangedCalledWithCorrectValues', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        buildSettingsResponse(bucketUrl: 'https://my-bucket.com', accessKey: 'myKey', accessSecret: 'mySecret'),
      ),
    );

    // ACT
    await initTestee();

    // EXPECT
    final capturedConfig = verify(mockCallbacks.awsCredentialsChanged(captureAny)).captured.single as AwsConfiguration;
    expect(capturedConfig.bucketUrl, 'https://my-bucket.com');
    expect(capturedConfig.accessKey, 'myKey');
    expect(capturedConfig.accessSecret, 'mySecret');
  });

  test('whenSettingsLoadedTwiceWithSamePreload_awsCredentialsChangedCalledOnlyOnce', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // ACT
    await initTestee();
    await testee.loadSettings();
    testAsync.flushMicrotasks();

    // EXPECT
    verify(mockCallbacks.awsCredentialsChanged(any)).called(1);
  });

  test('whenPreloadChangesOnSecondLoad_callsAwsCredentialsChangedAgain', () async {
    // ARRANGE
    when(
      mockSettingsRequest.call(),
    ).thenAnswer((_) => Future.value(buildSettingsResponse(bucketUrl: 'https://bucket1.com')));

    // ACT
    await initTestee();

    when(
      mockSettingsRequest.call(),
    ).thenAnswer((_) => Future.value(buildSettingsResponse(bucketUrl: 'https://bucket2.com')));
    await testee.loadSettings();

    // EXPECT
    verify(mockCallbacks.awsCredentialsChanged(any)).called(2);
  });

  test('whenNoAwsCredentialsCallback_doesNotThrowOnSuccessfulLoad', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // ACT & EXPECT – should not throw
    await initTestee(withAwsCallback: false);
    expect(await testee.loadSettings(), isTrue);
  });

  test('whenSettingsLoadedSuccessfully_loadSettingsReturnsTrue', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // ACT
    await initTestee();
    final result = await testee.loadSettings();

    // EXPECT
    expect(result, isTrue);
  });

  test('whenSettingsFetchFails_loadSettingsReturnsFalse', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();
    final result = await testee.loadSettings();

    // EXPECT
    expect(result, isFalse);
  });

  test('whenEmptyResponse_loadSettingsReturnsFalse', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        SettingsResponse(
          headers: {},
          body: SettingsResponseDto(data: List.empty()),
        ),
      ),
    );

    // ACT
    await initTestee();
    final result = await testee.loadSettings();

    // EXPECT
    expect(result, isFalse);
  });

  test('beforeSettingsLoaded_loggingTokenIsNull', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.loggingToken, isNull);
  });

  test('beforeSettingsLoaded_loggingUrlIsNull', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.loggingUrl, isNull);
  });

  test('whenSettingsLoadedSuccessfully_loggingTokenIsAvailable', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(loggingToken: 'my-logging-token')),
    );

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.loggingToken, 'my-logging-token');
  });

  test('whenSettingsLoadedSuccessfully_loggingUrlIsAvailable', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(loggingUrl: 'https://logs.example.com')),
    );

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.loggingUrl, 'https://logs.example.com');
  });

  test('whenRuFeatureIsEnabled_isRuFeatureEnabledReturnsTrue', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(settingsDatabaseService.findRuFeature('SBB', RuFeatureKeys.warnapp)).thenAnswer(
      (_) => Future.value(RuFeatureDto(companyCodeRics: 'SBB', key: RuFeatureKeys.warnapp.key, enabled: true)),
    );

    // ACT
    final result = await testee.isRuFeatureEnabled(RuFeatureKeys.warnapp, 'SBB');

    // EXPECT
    expect(result, isTrue);
  });

  test('whenRuFeatureIsDisabled_isRuFeatureEnabledReturnsFalse', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(settingsDatabaseService.findRuFeature('SBB', RuFeatureKeys.warnapp)).thenAnswer(
      (_) => Future.value(RuFeatureDto(companyCodeRics: 'SBB', key: RuFeatureKeys.warnapp.key, enabled: false)),
    );

    // ACT
    final result = await testee.isRuFeatureEnabled(RuFeatureKeys.warnapp, 'SBB');

    // EXPECT
    expect(result, isFalse);
  });

  test('whenRuFeatureNotFound_isRuFeatureEnabledReturnsFalse', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(
      settingsDatabaseService.findRuFeature('UNKNOWN', RuFeatureKeys.customerOrientedDeparture),
    ).thenAnswer((_) => Future.value(null));

    // ACT
    final result = await testee.isRuFeatureEnabled(RuFeatureKeys.customerOrientedDeparture, 'UNKNOWN');

    // EXPECT
    expect(result, isFalse);
  });

  test('whenRuFeatureChecked_queriesDatabaseWithCorrectArguments', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(
      settingsDatabaseService.findRuFeature('OBB', RuFeatureKeys.departureProcess),
    ).thenAnswer((_) => Future.value(null));

    // ACT
    await testee.isRuFeatureEnabled(RuFeatureKeys.departureProcess, 'OBB');

    // EXPECT
    verify(settingsDatabaseService.findRuFeature('OBB', RuFeatureKeys.departureProcess)).called(1);
  });

  test('beforeSettingsLoaded_appVersionExpirationIsNull', () async {
    // ARRANGE
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.appVersionExpiration, isNull);
  });

  test('whenSettingsLoadedSuccessfully_appVersionExpirationIsNotNull', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.appVersionExpiration, isNotNull);
    expect(testee.appVersionExpiration, isA<AppVersionExpiration>());
  });

  test('whenSettingsLoadedWithExpiredVersion_appVersionExpirationReturnsExpiredTrue', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(appVersionExpired: true)));

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.appVersionExpiration!.expired, isTrue);
  });

  test('whenSettingsLoadedWithExpiredVersion_awsCallbackCalledWithNull', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(appVersionExpired: true)));

    // ACT
    await initTestee();

    // EXPECT
    verify(mockCallbacks.awsCredentialsChanged(null)).called(1);
  });

  test('whenSettingsLoadedWithNonExpiredVersion_appVersionExpirationReturnsExpiredFalse', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(appVersionExpired: false)));

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.appVersionExpiration!.expired, isFalse);
  });

  test('whenSettingsLoadedWithExpiryDate_appVersionExpirationReturnsCorrectExpiryDate', () async {
    // ARRANGE
    final expiryDate = DateTime(2026, 12, 31);
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(appVersionExpired: false, appVersionExpiryDate: expiryDate)),
    );

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.appVersionExpiration!.expiryDate, expiryDate);
  });

  test('whenSettingsLoadedWithNoExpiryDate_appVersionExpirationHasNullExpiryDate', () async {
    // ARRANGE
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(appVersionExpired: false, appVersionExpiryDate: null)),
    );

    // ACT
    await initTestee();

    // EXPECT
    expect(testee.appVersionExpiration!.expiryDate, isNull);
  });
}

abstract class Callbacks extends Mock {
  void awsCredentialsChanged(AwsConfiguration config);
}
