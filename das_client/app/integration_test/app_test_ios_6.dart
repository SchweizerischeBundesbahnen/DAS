import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/train_journey_replacement_series_test.dart' as train_journey_replacement_series_test;
import 'test/train_journey_table_time_test.dart' as train_journey_table_time_tests;
import 'test/train_reduced_journey_test.dart' as train_reduced_journey_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  train_journey_replacement_series_test.main();
  train_reduced_journey_tests.main();
  train_journey_table_time_tests.main();
}
