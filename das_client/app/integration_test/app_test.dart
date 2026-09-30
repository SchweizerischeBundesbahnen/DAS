import 'dart:io';

import 'package:app/i18n/i18n.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/personal_notes_test.dart' as personal_notes_tests;

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

  //additional_speed_restriction_modal_tests.main();
  //automatic_advancement_tests.main();
  //app_expiration_tests.main();
  //app_link_tests.main();
  //brake_load_slip_tests.main();
  //chronograph_tests.main();
  //close_journey_tests.main();
  //departure_process_tests.main();
  //journey_customer_oriented_departure_tests.main();
  //journey_header_tests.main();
  //journey_notification_tests.main();
  //journey_table_additional_speed_restriction_tests.main();
  //journey_table_balise_level_crossing_tests.main();
  //journey_replacement_series_tests.main();
  //journey_search_overlay_tests.main();
  //journey_table_advised_speeds_tests.main();
  //journey_table_brake_series_tests.main();
  //journey_table_calculated_speed_tests.main();
  //journey_table_collapsible_rows_tests.main();
  //journey_table_station_property_tests.main();
  //journey_table_updates_tests.main();
  //journey_table_tests.main();
  //journey_table_time_tests.main();
  //journey_table_track_equipment_tests.main();
  //journey_validation_tests.main();
  //login_tests.main();
  //manual_advancement_tests.main();
  //navigation_tests.main();
  //reduced_journey_table_tests.main();
  //ru_indications_tests.main();
  personal_notes_tests.main();
  //service_point_modal_tests.main();
  //settings_tests.main();
  //short_term_changes_tests.main();
  //suspicious_segment_tests.main();
  //train_search_tests.main();
  //warnapp_tests.main();
  //preload_tests.main();
  //tour_system_link_test.main();
  //external_links_tests.main();
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
