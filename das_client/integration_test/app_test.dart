import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_de.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'di.dart';
import 'test/automatic_advancement_test.dart' as automatic_advancement_tests;
import 'test/train_journey_table_test.dart' as train_journey_table_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //Fimber.plantTree(DebugTree());

  train_journey_table_tests.main();
  // navigation_tests.main();
  // train_search_tests.main();
  automatic_advancement_tests.main();
}

Future<void> prepareAndStartApp(WidgetTester tester) async {
  // iOS workaround for enterText not working on some devices, if its the first element
  // (https://github.com/leancodepl/patrol/issues/1868#issuecomment-1814241939)
  tester.testTextInput.register();

  await IntegrationTestDI.init(Flavor.dev);
  runDasApp();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
