import 'package:das_client/app/i18n/gen/app_localizations_de.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:fimber/fimber.dart';
import 'package:integration_test/integration_test.dart';

import 'test/train_journey_header_test.dart' as train_journey_header_tests;
import 'test/train_journey_notification_test.dart' as train_journey_notification_tests;
import 'test/train_reduced_journey_test.dart' as train_reduced_journey_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  train_reduced_journey_tests.main();
  train_journey_header_tests.main();
  train_journey_notification_tests.main();
}
