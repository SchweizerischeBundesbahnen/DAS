import 'package:app/app/i18n/gen/app_localizations_de.dart';
import 'package:app/app/i18n/i18n.dart';
import 'package:fimber/fimber.dart';
import 'package:integration_test/integration_test.dart';

import 'test/train_journey_table_test.dart' as train_journey_table_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  train_journey_table_tests.main();
}
