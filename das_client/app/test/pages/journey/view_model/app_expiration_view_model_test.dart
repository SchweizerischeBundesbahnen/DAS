import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
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
  late AppExpirationViewModel testee;
  late MockSettingsRepository mockSettingsRepository;
  const appVersionFixture = 'someAppVersion';

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => true);
    when(mockSettingsRepository.appVersionExpiration).thenReturn(null);

    testee = AppExpirationViewModel(settingsRepository: mockSettingsRepository, currentAppVersion: 'fakeAppVersion');
  });

  tearDown(() {
    testee.dispose();
  });

  test('modelValue_whenNoExpirationSetting_thenReturnsValid', () async {
    // ARRANGE & ACT
    await processStreams();

    // EXPECT
    expect(testee.modelValue, Valid(currentAppVersion: ''));
  });

  test('modelValue_whenNotExpiredAndNoExpiryDate_thenReturnsValid', () async {
    // ARRANGE
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: false),
    );

    // ACT
    testee.checkIsAppExpired();
    await processStreams();

    // EXPECT
    expect(testee.modelValue, Valid(currentAppVersion: appVersionFixture));
  });

  test('modelValue_whenExpiredIsTrue_thenReturnsExpired', () async {
    // ARRANGE
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: true),
    );

    // ACT
    testee.checkIsAppExpired();
    await processStreams();

    // EXPECT
    expect(testee.modelValue, Expired(currentAppVersion: appVersionFixture));
  });

  test('modelValue_whenExpiryDateIsInFuture_thenReturnsExpirySoon', () async {
    // ARRANGE
    final expiryDate = DateTime.now().add(const Duration(days: 5));
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: false, expiryDate: expiryDate),
    );

    // ACT
    testee.checkIsAppExpired();
    await processStreams();

    // EXPECT
    expect(
      testee.modelValue,
      ExpirySoon(expiryDate: expiryDate, userDismissedDialog: false, currentAppVersion: appVersionFixture),
    );
  });

  test('mustShowDialog_whenExpired_thenReturnsTrue', () async {
    // ARRANGE
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: true),
    );

    // ACT
    testee.checkIsAppExpired();
    await processStreams();

    // EXPECT
    expect(testee.mustShowDialog, isTrue);
  });

  test('mustShowDialog_whenExpirySoonAndDialogNotDismissed_thenReturnsTrue', () async {
    // ARRANGE
    final expiryDate = DateTime.now().add(const Duration(days: 5));
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: false, expiryDate: expiryDate),
    );

    // ACT
    testee.checkIsAppExpired();
    await processStreams();

    // EXPECT
    expect(testee.mustShowDialog, isTrue);
  });

  test('mustShowDialog_whenValid_thenReturnsFalse', () async {
    // ARRANGE & ACT
    await processStreams();

    // EXPECT
    expect(testee.mustShowDialog, isFalse);
  });

  test('dismissDialog_whenExpirySoon_thenSetsUserDismissedDialogTrue', () async {
    // ARRANGE
    final expiryDate = DateTime.now().add(const Duration(days: 5));
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: false, expiryDate: expiryDate),
    );
    testee.checkIsAppExpired();
    await processStreams();

    // ACT
    testee.dialogDismissedByUser();
    await processStreams();

    // EXPECT
    expect(
      testee.modelValue,
      ExpirySoon(expiryDate: expiryDate, userDismissedDialog: true, currentAppVersion: appVersionFixture),
    );
    expect(testee.mustShowDialog, isFalse);
  });

  test('dismissDialog_whenCalledTwice_thenOnlyTakesEffectOnce', () async {
    // ARRANGE
    final expiryDate = DateTime.now().add(const Duration(days: 5));
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: false, expiryDate: expiryDate),
    );
    testee.checkIsAppExpired();
    await processStreams();

    // ACT
    testee.dialogDismissedByUser();
    testee.dialogDismissedByUser();
    await processStreams();

    // EXPECT
    expect(
      testee.modelValue,
      ExpirySoon(expiryDate: expiryDate, userDismissedDialog: true, currentAppVersion: appVersionFixture),
    );
  });

  test('model_whenCreated_thenEmitsValid', () async {
    // ARRANGE & ACT & EXPECT
    await expectLater(testee.model, emits(Valid(currentAppVersion: appVersionFixture)));
  });

  test('model_whenAppIsExpired_thenEmitsExpired', () async {
    // ARRANGE
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: true),
    );

    // ACT
    testee.checkIsAppExpired();

    // EXPECT
    await expectLater(testee.model, emitsThrough(Expired(currentAppVersion: appVersionFixture)));
  });

  test('modelValue_whenLoadSettingsReturnsFalse_thenRemainsValid', () async {
    // ARRANGE
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => false);
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: true),
    );

    // ACT
    testee.checkIsAppExpired();
    await processStreams();

    // EXPECT
    expect(testee.modelValue, Valid(currentAppVersion: appVersionFixture));
  });
}
