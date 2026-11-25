import 'dart:async';
import 'dart:io';

import 'package:core_data/component.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:settings/component.dart';
import 'package:settings/src/api/dto/app_version_expiration_dto.dart';
import 'package:settings/src/api/dto/company_dto.dart';
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
    List<CompanyDto> companies = const [],
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
            companies: companies,
            preload: PreloadDto(
              bucketUrl: bucketUrl,
              accessKey: accessKey,
              accessSecret: accessSecret,
              region: 'eu-central-1',
            ),
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
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();

    // THEN
    verify(apiService.settings).called(1);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenInitialized_RetriesAfterErrorWithDelay', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();
    testAsync.elapse(SettingsRepositoryImpl.retryDelay + Duration(milliseconds: 100));

    // THEN
    verify(apiService.settings).called(2);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenEmptyResponse_RetriesWithDelay', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        SettingsResponse(
          headers: {},
          body: SettingsResponseDto(data: List.empty()),
        ),
      ),
    );

    // WHEN
    await initTestee();
    testAsync.elapse(SettingsRepositoryImpl.retryDelay + Duration(milliseconds: 100));

    // THEN
    verify(apiService.settings).called(2);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenInitialized_MultipleErrorsRetryMultipleTimes', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();
    testAsync.elapse((SettingsRepositoryImpl.retryDelay * 3) + Duration(milliseconds: 100));

    // THEN
    verify(apiService.settings).called(4);
    verifyZeroInteractions(settingsDatabaseService);
  });

  test('whenSuccessAfterError_stopsRetrying', () async {
    // GIVEN
    var callCount = 0;
    when(apiService.settings).thenAnswer((_) {
      callCount++;
      if (callCount == 1) throw HttpException('Exception');
      return mockSettingsRequest;
    });
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // WHEN
    await initTestee();
    testAsync.elapse(SettingsRepositoryImpl.retryDelay * 2 + Duration(milliseconds: 100));

    // THEN
    verify(apiService.settings).called(2);
  });

  test('whenSettingsLoadedSuccessfully_savesRuFeaturesToDatabase', () async {
    // GIVEN
    final ruFeatures = [
      RuFeatureDto(companyCode: 'SBB', key: RuFeatureKeys.warnapp.key, enabled: true),
    ];
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(ruFeatures: ruFeatures)));

    // WHEN
    await initTestee();

    // THEN
    verify(settingsDatabaseService.replaceAllRuFeatures(ruFeatures)).called(1);
  });

  test('whenSettingsLoadedSuccessfully_callsAwsCredentialsChanged', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        buildSettingsResponse(bucketUrl: 'https://new-bucket.com', accessKey: 'key', accessSecret: 'secret'),
      ),
    );

    // WHEN
    await initTestee();

    // THEN
    verify(mockCallbacks.awsCredentialsChanged(any)).called(1);
  });

  test('whenSettingsLoadedSuccessfully_savesCompaniesToDatabase', () async {
    // GIVEN
    final companies = [
      CompanyDto(code: '1285', shortName: 'SBBP'),
      CompanyDto(code: '3356', shortName: 'BLSC'),
    ];
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(companies: companies)));

    // WHEN
    await initTestee();

    // THEN
    verify(settingsDatabaseService.replaceAllCompanies(companies)).called(1);
  });

  test('whenSettingsLoadedSuccessfully_awsCredentialsChangedCalledWithCorrectValues', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        buildSettingsResponse(bucketUrl: 'https://my-bucket.com', accessKey: 'myKey', accessSecret: 'mySecret'),
      ),
    );

    // WHEN
    await initTestee();

    // THEN
    final capturedConfig = verify(mockCallbacks.awsCredentialsChanged(captureAny)).captured.single as AwsConfiguration;
    expect(capturedConfig.bucketUrl, 'https://my-bucket.com');
    expect(capturedConfig.accessKey, 'myKey');
    expect(capturedConfig.accessSecret, 'mySecret');
  });

  test('whenSettingsLoadedTwiceWithSamePreload_awsCredentialsChangedCalledOnlyOnce', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // WHEN
    await initTestee();
    await testee.loadSettings();
    testAsync.flushMicrotasks();

    // THEN
    verify(mockCallbacks.awsCredentialsChanged(any)).called(1);
  });

  test('whenPreloadChangesOnSecondLoad_callsAwsCredentialsChangedAgain', () async {
    // GIVEN
    when(
      mockSettingsRequest.call(),
    ).thenAnswer((_) => Future.value(buildSettingsResponse(bucketUrl: 'https://bucket1.com')));

    // WHEN
    await initTestee();

    when(
      mockSettingsRequest.call(),
    ).thenAnswer((_) => Future.value(buildSettingsResponse(bucketUrl: 'https://bucket2.com')));
    await testee.loadSettings();

    // THEN
    verify(mockCallbacks.awsCredentialsChanged(any)).called(2);
  });

  test('whenNoAwsCredentialsCallback_doesNotThrowOnSuccessfulLoad', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // WHEN & THEN – should not throw
    await initTestee(withAwsCallback: false);
    expect(await testee.loadSettings(), isTrue);
  });

  test('whenSettingsLoadedSuccessfully_loadSettingsReturnsTrue', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // WHEN
    await initTestee();
    final result = await testee.loadSettings();

    // THEN
    expect(result, isTrue);
  });

  test('whenLoadSettingsCalledWhileLoadInProgress_sharesRequest', () async {
    // GIVEN
    final results = <bool>[];
    fakeAsync((fakeAsync) {
      final completer = Completer<SettingsResponse>();
      when(mockSettingsRequest.call()).thenAnswer((_) => completer.future);
      testee = SettingsRepositoryImpl(
        apiService: apiService,
        databaseService: settingsDatabaseService,
        onAwsCredentialsChanged: mockCallbacks.awsCredentialsChanged,
      );
      fakeAsync.flushMicrotasks();

      // WHEN
      testee.loadSettings().then(results.add);
      testee.loadSettings().then(results.add);
      completer.complete(buildSettingsResponse());
      fakeAsync.flushMicrotasks();
    });

    // THEN
    expect(results, [true, true]);
    verify(apiService.settings).called(1);
    verify(mockSettingsRequest.call()).called(1);
  });

  test('whenLoadSettingsCalledWhileLoadInProgressAndFails_allCallersReceiveFalse', () async {
    // GIVEN
    final results = <bool>[];
    fakeAsync((fakeAsync) {
      final completer = Completer<SettingsResponse>();
      when(mockSettingsRequest.call()).thenAnswer((_) => completer.future);
      testee = SettingsRepositoryImpl(
        apiService: apiService,
        databaseService: settingsDatabaseService,
        onAwsCredentialsChanged: mockCallbacks.awsCredentialsChanged,
      );
      fakeAsync.flushMicrotasks();

      // WHEN
      testee.loadSettings().then(results.add);
      testee.loadSettings().then(results.add);
      completer.completeError(HttpException('Exception'));
      fakeAsync.flushMicrotasks();
    });

    // THEN
    expect(results, [false, false]);
    verify(apiService.settings).called(1);
  });

  test('whenLoadSettingsCalledAfterPreviousLoadCompleted_triggersNewRequest', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // WHEN
    await initTestee();
    await testee.loadSettings();

    // THEN
    verify(apiService.settings).called(2);
    verify(mockSettingsRequest.call()).called(2);
  });

  test('whenSettingsFetchFails_loadSettingsReturnsFalse', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();
    final result = await testee.loadSettings();

    // THEN
    expect(result, isFalse);
  });

  test('whenEmptyResponse_loadSettingsReturnsFalse', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(
        SettingsResponse(
          headers: {},
          body: SettingsResponseDto(data: List.empty()),
        ),
      ),
    );

    // WHEN
    await initTestee();
    final result = await testee.loadSettings();

    // THEN
    expect(result, isFalse);
  });

  test('beforeSettingsLoaded_loggingTokenIsNull', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();

    // THEN
    expect(testee.loggingToken, isNull);
  });

  test('beforeSettingsLoaded_loggingUrlIsNull', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();

    // THEN
    expect(testee.loggingUrl, isNull);
  });

  test('whenSettingsLoadedSuccessfully_loggingTokenIsAvailable', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(loggingToken: 'my-logging-token')),
    );

    // WHEN
    await initTestee();

    // THEN
    expect(testee.loggingToken, 'my-logging-token');
  });

  test('whenSettingsLoadedSuccessfully_loggingUrlIsAvailable', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(loggingUrl: 'https://logs.example.com')),
    );

    // WHEN
    await initTestee();

    // THEN
    expect(testee.loggingUrl, 'https://logs.example.com');
  });

  test('whenRuFeatureIsEnabled_isRuFeatureEnabledReturnsTrue', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(settingsDatabaseService.findRuFeature('SBB', RuFeatureKeys.warnapp)).thenAnswer(
      (_) => Future.value(RuFeatureDto(companyCode: 'SBB', key: RuFeatureKeys.warnapp.key, enabled: true)),
    );

    // WHEN
    final result = await testee.isRuFeatureEnabled(RuFeatureKeys.warnapp, 'SBB');

    // THEN
    expect(result, isTrue);
  });

  test('whenRuFeatureIsDisabled_isRuFeatureEnabledReturnsFalse', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(settingsDatabaseService.findRuFeature('SBB', RuFeatureKeys.warnapp)).thenAnswer(
      (_) => Future.value(RuFeatureDto(companyCode: 'SBB', key: RuFeatureKeys.warnapp.key, enabled: false)),
    );

    // WHEN
    final result = await testee.isRuFeatureEnabled(RuFeatureKeys.warnapp, 'SBB');

    // THEN
    expect(result, isFalse);
  });

  test('whenRuFeatureNotFound_isRuFeatureEnabledReturnsFalse', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(
      settingsDatabaseService.findRuFeature('UNKNOWN', RuFeatureKeys.customerOrientedDeparture),
    ).thenAnswer((_) => Future.value(null));

    // WHEN
    final result = await testee.isRuFeatureEnabled(RuFeatureKeys.customerOrientedDeparture, 'UNKNOWN');

    // THEN
    expect(result, isFalse);
  });

  test('whenRuFeatureChecked_queriesDatabaseWithCorrectArguments', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(
      settingsDatabaseService.findRuFeature('OBB', RuFeatureKeys.departureProcess),
    ).thenAnswer((_) => Future.value(null));

    // WHEN
    await testee.isRuFeatureEnabled(RuFeatureKeys.departureProcess, 'OBB');

    // THEN
    verify(settingsDatabaseService.findRuFeature('OBB', RuFeatureKeys.departureProcess)).called(1);
  });

  test('whenLoadCompanies_returnsAllCompaniesFromDatabase', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));
    await initTestee();
    when(settingsDatabaseService.findAllCompanies()).thenAnswer(
      (_) => Future.value([
        CompanyDto(code: '1285', shortName: 'SBBP'),
        CompanyDto(code: '3356', shortName: 'BLSC'),
      ]),
    );

    // WHEN
    final result = await testee.getCompanies();

    // THEN
    expect(result, [
      Company(code: '1285', shortName: 'SBBP'),
      Company(code: '3356', shortName: 'BLSC'),
    ]);
  });

  test('beforeSettingsLoaded_appVersionExpirationIsNull', () async {
    // GIVEN
    when(apiService.settings).thenAnswer((_) => throw HttpException('Exception'));

    // WHEN
    await initTestee();

    // THEN
    expect(testee.appVersionExpiration, isNull);
  });

  test('whenSettingsLoadedSuccessfully_appVersionExpirationIsNotNull', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse()));

    // WHEN
    await initTestee();

    // THEN
    expect(testee.appVersionExpiration, isNotNull);
    expect(testee.appVersionExpiration, isA<AppVersionExpiration>());
  });

  test('whenSettingsLoadedWithExpiredVersion_appVersionExpirationReturnsExpiredTrue', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(appVersionExpired: true)));

    // WHEN
    await initTestee();

    // THEN
    expect(testee.appVersionExpiration!.expired, isTrue);
  });

  test('whenSettingsLoadedWithExpiredVersion_awsCallbackCalledWithNull', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(appVersionExpired: true)));

    // WHEN
    await initTestee();

    // THEN
    verify(mockCallbacks.awsCredentialsChanged(null)).called(1);
  });

  test('whenSettingsLoadedWithNonExpiredVersion_appVersionExpirationReturnsExpiredFalse', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer((_) => Future.value(buildSettingsResponse(appVersionExpired: false)));

    // WHEN
    await initTestee();

    // THEN
    expect(testee.appVersionExpiration!.expired, isFalse);
  });

  test('whenSettingsLoadedWithExpiryDate_appVersionExpirationReturnsCorrectExpiryDate', () async {
    // GIVEN
    final expiryDate = DateTime(2026, 12, 31);
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(appVersionExpired: false, appVersionExpiryDate: expiryDate)),
    );

    // WHEN
    await initTestee();

    // THEN
    expect(testee.appVersionExpiration!.expiryDate, expiryDate);
  });

  test('whenSettingsLoadedWithNoExpiryDate_appVersionExpirationHasNullExpiryDate', () async {
    // GIVEN
    when(mockSettingsRequest.call()).thenAnswer(
      (_) => Future.value(buildSettingsResponse(appVersionExpired: false, appVersionExpiryDate: null)),
    );

    // WHEN
    await initTestee();

    // THEN
    expect(testee.appVersionExpiration!.expiryDate, isNull);
  });
}

abstract class Callbacks extends Mock {
  void awsCredentialsChanged(AwsConfiguration config);
}
