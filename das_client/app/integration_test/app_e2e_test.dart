import 'dart:io';

import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/das_base_scope.dart';
import 'package:app/di/scopes/sfera_mock_scope.dart';
import 'package:app/flavor.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'integration_test_di.dart';
import 'test/preload_e2e_test.dart' as preload_e2e_tests;
import 'util/test_utils.dart';

late AppLocalizations l10n;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  setUpAll(() async {
    await _useFullyLivePolicyOnAndroidEmulator(binding);
  });

  tearDown(() async {
    await _delayOnAndroidEmulator();
  });

  preload_e2e_tests.main();
}

Future<void> prepareAndStartApp(WidgetTester tester, {VoidCallback? onBeforeRun}) async {
  // iOS workaround for enterText not working on some devices, if its the first element
  // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
  tester.testTextInput.register();

  await IntegrationTestDI.init(Flavor.dev(), e2e: true); // registers flavor, mockScopes and scope handler

  final scopeHandler = IntegrationTestDI.get<ScopeHandler>();
  await scopeHandler.push<DASBaseScope>();
  await scopeHandler.push<SferaMockScope>();

  l10n = await deviceLocalizations();
  onBeforeRun?.call();

  runDasApp();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// delay can improve stability on Android emulator
Future<void> _delayOnAndroidEmulator() async {
  if (await _isAndroidEmulator()) {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

Future<void> _useFullyLivePolicyOnAndroidEmulator(TestWidgetsFlutterBinding binding) async {
  if (binding is LiveTestWidgetsFlutterBinding && await _isAndroidEmulator()) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }
}

Future<bool> _isAndroidEmulator() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return !androidInfo.isPhysicalDevice;
  }
  return false;
}
