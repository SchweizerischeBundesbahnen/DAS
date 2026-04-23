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

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.loadSettings()).thenAnswer((_) async => true);
    when(mockSettingsRepository.appVersionExpiration).thenReturn(null);

    testee = AppExpirationViewModel(settingsRepository: mockSettingsRepository);
  });

  tearDown(() {
    testee.dispose();
  });

  test('modelValue_whenNoExpirationSetting_thenReturnsValid', () async {
    // ARRANGE & ACT
    await processStreams();

    // EXPECT
    expect(testee.modelValue, Valid());
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
    expect(testee.modelValue, Valid());
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
    expect(testee.modelValue, Expired());
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
    expect(testee.modelValue, ExpirySoon(expiryDate: expiryDate, userDismissedDialog: false));
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
    testee.dismissDialog();
    await processStreams();

    // EXPECT
    expect(testee.modelValue, ExpirySoon(expiryDate: expiryDate, userDismissedDialog: true));
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
    testee.dismissDialog();
    testee.dismissDialog();
    await processStreams();

    // EXPECT
    expect(testee.modelValue, ExpirySoon(expiryDate: expiryDate, userDismissedDialog: true));
  });

  test('model_whenCreated_thenEmitsValid', () async {
    // ARRANGE & ACT & EXPECT
    await expectLater(testee.model, emits(Valid()));
  });

  test('model_whenAppIsExpired_thenEmitsExpired', () async {
    // ARRANGE
    when(mockSettingsRepository.appVersionExpiration).thenReturn(
      AppVersionExpiration(expired: true),
    );

    // ACT
    testee.checkIsAppExpired();

    // EXPECT
    await expectLater(testee.model, emitsThrough(Expired()));
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
    expect(testee.modelValue, Valid());
  });
}
