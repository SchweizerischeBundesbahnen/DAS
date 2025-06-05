import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:fimber/fimber.dart';
import 'package:integration_test/integration_test.dart';

import 'test/warnapp_test.dart' as warnapp_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  warnapp_tests.main();
}
