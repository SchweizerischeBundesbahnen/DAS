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
import 'test/additional_speed_restriction_modal_test.dart' as additional_speed_restriction_modal_test;
import 'test/automatic_advancement_test.dart' as automatic_advancement_tests;
import 'test/journey_header_test.dart' as journey_header_tests;
import 'test/journey_notification_test.dart' as journey_notification_tests;
import 'test/journey_replacement_series_test.dart' as journey_replacement_series_test;
import 'test/journey_search_overlay_test.dart' as journey_search_overlay_tests;
import 'test/journey_table_advised_speeds_test.dart' as journey_table_adl_tests;
import 'test/journey_table_break_series_test.dart' as journey_table_break_series_tests;
import 'test/journey_table_calculated_speed_test.dart' as journey_table_calculated_speed_tests;
import 'test/journey_table_collapsible_rows_test.dart' as journey_table_collapsible_rows_test;
import 'test/journey_table_station_property_test.dart' as journey_table_station_property_test;
import 'test/journey_table_test.dart' as journey_table_tests;
import 'test/journey_table_time_test.dart' as journey_table_time_tests;
import 'test/journey_table_track_equipment_test.dart' as journey_table_track_equipment_tests;
import 'test/navigation_test.dart' as navigation_tests;
import 'test/reduced_journey_table_test.dart' as reduced_journey_table_tests;
import 'test/service_point_modal_test.dart' as service_point_modal_test;
import 'test/settings_test.dart' as settings_test;
import 'test/train_search_test.dart' as train_search_tests;
import 'test/warnapp_test.dart' as warnapp_tests;
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

  settings_test.main();
  reduced_journey_table_tests.main();
  journey_table_tests.main();
  journey_table_time_tests.main();
  journey_header_tests.main();
  journey_table_track_equipment_tests.main();
  journey_table_break_series_tests.main();
  journey_table_calculated_speed_tests.main();
  journey_table_collapsible_rows_test.main();
  journey_notification_tests.main();
  navigation_tests.main();
  train_search_tests.main();
  automatic_advancement_tests.main();
  service_point_modal_test.main();
  journey_search_overlay_tests.main();
  additional_speed_restriction_modal_test.main();
  warnapp_tests.main();
  journey_table_station_property_test.main();
  journey_table_adl_tests.main();
  journey_replacement_series_test.main();
}

Future<void> prepareAndStartApp(WidgetTester tester, {VoidCallback? onBeforeRun}) async {
  // iOS workaround for enterText not working on some devices, if its the first element
  // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
  tester.testTextInput.register();

  await IntegrationTestDI.init(Flavor.dev()); // registers flavor, mockScopes and scope handler

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
