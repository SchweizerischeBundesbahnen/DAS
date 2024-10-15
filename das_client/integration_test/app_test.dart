import 'package:das_client/flavor.dart';
import 'package:das_client/i18n/i18n.dart';
import 'package:das_client/main.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_de.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'di.dart';
import 'test/fahrbild_test.dart' as FahrbildTests;
import 'test/navigation_test.dart' as NavigationTests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  FahrbildTests.main();
  NavigationTests.main();
}

Future<void> prepareAndStartApp(WidgetTester tester) async {
  await IntegrationTestDI.init(Flavor.dev);
  runDasApp();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
