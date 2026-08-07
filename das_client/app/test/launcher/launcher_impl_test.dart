import 'package:app/flavor.dart';
import 'package:app/launcher/launcher_impl.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/model/journey_navigation_model.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import 'launcher_impl_test.mocks.dart';

const _urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

@GenerateNiceMocks([
  MockSpec<LocalKeyValueStore>(),
  MockSpec<JourneyNavigationViewModel>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LauncherImpl testee;
  late MockLocalKeyValueStore mockLocalKeyValueStore;
  late List<MethodCall> methodCalls;
  late bool launchResult;

  setUp(() {
    mockLocalKeyValueStore = MockLocalKeyValueStore();
    methodCalls = <MethodCall>[];
    launchResult = true;

    when(mockLocalKeyValueStore.companyCodes).thenReturn(['1285']);
    when(mockLocalKeyValueStore.tourSystem).thenReturn(.tip);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _urlLauncherChannel,
      (call) async {
        methodCalls.add(call);
        if (call.method == 'launchUrl' || call.method == 'launch') {
          return launchResult;
        }
        return null;
      },
    );

    testee = LauncherImpl(userSettings: mockLocalKeyValueStore, flavor: Flavor.dev());
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _urlLauncherChannel,
      null,
    );
    await GetIt.I.reset();
  });

  test('launch_whenUrlIsInvalid_thenReturnsFalseAndDoesNotCallPlatform', () async {
    final result = await testee.launch('http://[::1');

    expect(result, false);
    expect(methodCalls, isEmpty);
  });

  test('launch_whenUrlIsValid_thenCallsPlatformAndReturnsResult', () async {
    launchResult = true;

    final result = await testee.launch('https://example.com');

    expect(result, true);
    expect(_hasLaunchCall(methodCalls), true);
    expect(_containsLaunchedUrl(methodCalls, 'https://example.com'), true);
  });

  test('hasTourSystemConfigured_whenJourneyReturnUrlIsPresent_thenReturnsTrue', () {
    final navigationViewModel = MockJourneyNavigationViewModel();
    when(navigationViewModel.modelValue).thenReturn(
      JourneyNavigationModel(
        trainIdentification: ExtendedTrainIdentification(
          trainIdentification: TrainIdentification(
            companyCode: '1285',
            trainNumber: '1234',
            date: DateTime(2026, 1, 1),
          ),
          returnUrl: 'https://return.example.com',
        ),
        currentIndex: 0,
        navigationStackLength: 1,
        showNavigationButtons: false,
      ),
    );
    GetIt.I.registerSingleton<JourneyNavigationViewModel>(navigationViewModel);

    final result = testee.hasTourSystemConfigured();

    expect(result, true);
  });

  test('launchTourSystem_whenJourneyReturnUrlIsPresent_thenLaunchesReturnUrl', () async {
    final navigationViewModel = MockJourneyNavigationViewModel();
    when(navigationViewModel.modelValue).thenReturn(
      JourneyNavigationModel(
        trainIdentification: ExtendedTrainIdentification(
          trainIdentification: TrainIdentification(
            companyCode: '1285',
            trainNumber: '1234',
            date: DateTime(2026, 1, 1),
          ),
          returnUrl: 'https://return.example.com',
        ),
        currentIndex: 0,
        navigationStackLength: 1,
        showNavigationButtons: false,
      ),
    );
    GetIt.I.registerSingleton<JourneyNavigationViewModel>(navigationViewModel);

    final result = await testee.launchTourSystem();

    expect(result, true);
    expect(_containsLaunchedUrl(methodCalls, 'https://return.example.com'), true);
  });

  test('launchServicePointPortal_whenAllRusAreBls_thenUsesBlsPortal', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['3356', '1163']);

    final result = await testee.launchServicePointPortal(
      const ServicePoint(name: 'Bern', abbreviation: 'BERN', locationCode: '8507000', order: 1000, kilometre: []),
    );

    expect(result, true);
    expect(_containsLaunchedUrl(methodCalls, 'bls.sharepoint.com'), true);
    expect(_containsLaunchedUrl(methodCalls, 'BERN'), true);
  });

  test('launchServicePointPortal_whenNoRuSelected_thenUsesSbbPortal', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn([]);

    final result = await testee.launchServicePointPortal(
      const ServicePoint(name: 'Bern', abbreviation: 'BERN', locationCode: '8507000', order: 1000, kilometre: []),
    );

    expect(result, true);
    expect(_containsLaunchedUrl(methodCalls, 'sbb.sharepoint.com'), true);
    expect(_containsLaunchedUrl(methodCalls, 'BERN'), true);
  });

  test('launchServicePointPortal_whenRuSelectionIsMixedBlsAndSbb_thenUsesSbbPortal', () async {
    when(mockLocalKeyValueStore.companyCodes).thenReturn(['1163', '1285']);

    final result = await testee.launchServicePointPortal(
      const ServicePoint(name: 'Bern', abbreviation: 'BERN', locationCode: '8507000', order: 1000, kilometre: []),
    );

    expect(result, true);
    expect(_containsLaunchedUrl(methodCalls, 'sbb.sharepoint.com'), true);
    expect(_containsLaunchedUrl(methodCalls, 'BERN'), true);
  });
}

bool _hasLaunchCall(List<MethodCall> methodCalls) {
  return methodCalls.any((call) => call.method == 'launchUrl' || call.method == 'launch');
}

bool _containsLaunchedUrl(List<MethodCall> methodCalls, String expectedUrlPart) {
  for (final call in methodCalls) {
    if (call.method != 'launchUrl' && call.method != 'launch') continue;

    final arguments = call.arguments;
    if (arguments is Map && arguments['url'] is String) {
      if ((arguments['url'] as String).contains(expectedUrlPart)) {
        return true;
      }
    } else if (arguments is String && arguments.contains(expectedUrlPart)) {
      return true;
    } else if ('$arguments'.contains(expectedUrlPart)) {
      return true;
    }
  }
  return false;
}
