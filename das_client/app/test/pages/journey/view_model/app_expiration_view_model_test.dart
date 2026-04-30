import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:settings/component.dart';

import '../../../test_util.dart';
import 'app_expiration_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SettingsRepository>(),
])
void main() {
  const appVersionFixture = 'someAppVersion';

  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => true);
    when(mockSettingsRepository.appVersionExpiration).thenReturn(null);
  });

  AppExpirationViewModel createTestee(FakeAsync async) {
    final testee = AppExpirationViewModel(
      settingsRepository: mockSettingsRepository,
      currentAppVersion: appVersionFixture,
    );
    async.flushMicrotasks(); // emit streams
    return testee;
  }

  test('modelValue_whenNoExpirationSetting_thenReturnsValid', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);

      expect(testee.modelValue, Valid(currentAppVersion: appVersionFixture));

      testee.dispose();
    });
  });

  test('modelValue_whenNotExpiredAndNoExpiryDate_thenReturnsValid', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero); // first load completes, throttle starts
      when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: false));

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      expect(testee.modelValue, Valid(currentAppVersion: appVersionFixture));

      testee.dispose();
    });
  });

  test('modelValue_whenExpiredIsTrue_thenReturnsExpired', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: true));

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      expect(testee.modelValue, Expired(currentAppVersion: appVersionFixture));

      testee.dispose();
    });
  });

  test('modelValue_whenExpiryDateIsInFuture_thenReturnsExpirySoon', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      final expiryDate = DateTime.now().add(const Duration(days: 5));
      when(mockSettingsRepository.appVersionExpiration).thenReturn(
        AppVersionExpiration(expired: false, expiryDate: expiryDate),
      );

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      expect(
        testee.modelValue,
        ExpirySoon(expiryDate: expiryDate, userDismissedDialog: false, currentAppVersion: appVersionFixture),
      );

      testee.dispose();
    });
  });

  test('mustShowDialog_whenExpired_thenReturnsTrue', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: true));

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      expect(testee.mustShowDialog, isTrue);

      testee.dispose();
    });
  });

  test('mustShowDialog_whenExpirySoonAndDialogNotDismissed_thenReturnsTrue', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      final expiryDate = DateTime.now().add(const Duration(days: 5));
      when(mockSettingsRepository.appVersionExpiration).thenReturn(
        AppVersionExpiration(expired: false, expiryDate: expiryDate),
      );

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      expect(testee.mustShowDialog, isTrue);

      testee.dispose();
    });
  });

  test('mustShowDialog_whenValid_thenReturnsFalse', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);

      expect(testee.mustShowDialog, isFalse);

      testee.dispose();
    });
  });

  test('dismissDialog_whenExpirySoon_thenSetsUserDismissedDialogTrue', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      final expiryDate = DateTime.now().add(const Duration(days: 5));
      when(mockSettingsRepository.appVersionExpiration).thenReturn(
        AppVersionExpiration(expired: false, expiryDate: expiryDate),
      );

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      testee.dialogDismissedByUser();

      expect(
        testee.modelValue,
        ExpirySoon(expiryDate: expiryDate, userDismissedDialog: true, currentAppVersion: appVersionFixture),
      );
      expect(testee.mustShowDialog, isFalse);

      testee.dispose();
    });
  });

  test('dismissDialog_whenCalledTwice_thenOnlyTakesEffectOnce', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      final expiryDate = DateTime.now().add(const Duration(days: 5));
      when(mockSettingsRepository.appVersionExpiration).thenReturn(
        AppVersionExpiration(expired: false, expiryDate: expiryDate),
      );

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      testee.dialogDismissedByUser();
      testee.dialogDismissedByUser();

      expect(
        testee.modelValue,
        ExpirySoon(expiryDate: expiryDate, userDismissedDialog: true, currentAppVersion: appVersionFixture),
      );

      testee.dispose();
    });
  });

  test('model_whenCreated_thenEmitsValid', () async {
    final testee = AppExpirationViewModel(
      settingsRepository: mockSettingsRepository,
      currentAppVersion: appVersionFixture,
    );
    expect(await testee.model.first, Valid(currentAppVersion: appVersionFixture));
    testee.dispose();
  });

  test('model_whenAppIsExpired_thenEmitsExpired', () async {
    when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: true));
    final testee = AppExpirationViewModel(
      settingsRepository: mockSettingsRepository,
      currentAppVersion: appVersionFixture,
    );
    await processStreams();
    expect(await testee.model.first, Expired(currentAppVersion: appVersionFixture));
    testee.dispose();
  });

  test('modelValue_whenLoadSettingsReturnsFalse_thenRemainsValid', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => false);
      when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: true));

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      expect(testee.modelValue, Valid(currentAppVersion: appVersionFixture));

      testee.dispose();
    });
  });

  test('checkIsAppExpired_whenLoadInProgress_doesNotCallLoadSettingsAgain', () {
    fakeAsync((async) {
      // createTestee calls flushMicrotasks, but the async loadSettings Future
      // hasn't resolved yet from the constructor – _isLoading is true
      final testee = createTestee(async);

      testee.checkIsAppExpired();
      testee.checkIsAppExpired();

      // Only the single constructor-initiated call should have been made
      verify(mockSettingsRepository.loadSettings()).called(1);

      testee.dispose();
    });
  });

  test('checkIsAppExpired_whenCalledDuringThrottle_doesNotCallLoadSettingsAgain', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero); // first load completes, throttle timer starts
      when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: false));

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();
      verify(mockSettingsRepository.loadSettings()).called(2);
      clearInteractions(mockSettingsRepository);

      // ACT – call again before throttle expires
      async.elapse(Duration(milliseconds: AppExpirationViewModel.throttleDuration.inMilliseconds ~/ 2));
      testee.checkIsAppExpired();
      testee.checkIsAppExpired();

      verifyNever(mockSettingsRepository.loadSettings());

      testee.dispose();
    });
  });

  test('checkIsAppExpired_whenThrottleExpires_allowsLoadSettingsAgain', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.elapse(Duration.zero);
      when(mockSettingsRepository.appVersionExpiration).thenReturn(AppVersionExpiration(expired: false));

      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();
      verify(mockSettingsRepository.loadSettings()).called(2);
      clearInteractions(mockSettingsRepository);

      // ACT – wait for throttle to expire, then call again
      async.elapse(AppExpirationViewModel.throttleDuration + const Duration(milliseconds: 100));
      testee.checkIsAppExpired();
      async.flushMicrotasks();

      verify(mockSettingsRepository.loadSettings()).called(1);

      testee.dispose();
    });
  });

  test('checkIsAppExpired_whenLastSettingIsNull_loadsImmediately', () {
    fakeAsync((async) {
      final testee = createTestee(async);
      async.flushMicrotasks();

      // The constructor call is the only loadSettings call when _lastSetting is null
      verify(mockSettingsRepository.loadSettings()).called(1);

      testee.dispose();
    });
  });
}
