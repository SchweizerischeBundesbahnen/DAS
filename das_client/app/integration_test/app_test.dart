import 'dart:ui';

import 'package:app/flavor.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/main.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'di.dart';
import 'test/additional_speed_restriction_modal_test.dart' as additional_speed_restriction_modal_test;
import 'test/automatic_advancement_test.dart' as automatic_advancement_tests;
import 'test/navigation_test.dart' as navigation_tests;
import 'test/service_point_modal_test.dart' as service_point_modal_test;
import 'test/train_journey_header_test.dart' as train_journey_header_tests;
import 'test/train_journey_notification_test.dart' as train_journey_notification_tests;
import 'test/train_journey_table_test.dart' as train_journey_table_tests;
import 'test/train_reduced_journey_test.dart' as train_reduced_journey_tests;
import 'test/train_search_test.dart' as train_search_tests;
import 'test/warnapp_test.dart' as warnapp_tests;
import 'util/test_utils.dart';

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  train_reduced_journey_tests.main();
  train_journey_table_tests.main();
  train_journey_header_tests.main();
  train_journey_notification_tests.main();
  navigation_tests.main();
  train_search_tests.main();
  automatic_advancement_tests.main();
  service_point_modal_test.main();
  additional_speed_restriction_modal_test.main();
  warnapp_tests.main();
}

Future<void> prepareAndStartApp(WidgetTester tester, {VoidCallback? onBeforeRun}) async {
  // iOS workaround for enterText not working on some devices, if its the first element
  // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
  tester.testTextInput.register();

  await IntegrationTestDI.init(Flavor.dev);
  l10n = await deviceLocalizations();
  onBeforeRun?.call();
  runDasApp();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
