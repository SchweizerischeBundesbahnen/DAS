import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/preload_e2e_test.dart' as preload_e2e_tests;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS E2ETests').call);

  setUpAll(() async {
    await _useFullyLivePolicyOnAndroidEmulator(binding);
  });

  tearDown(() async {
    await _delayOnAndroidEmulator();
  });

  preload_e2e_tests.main();
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
