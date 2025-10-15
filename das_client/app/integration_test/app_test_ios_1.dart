import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/train_journey_table_test.dart' as train_journey_table_tests;
import 'test/train_reduced_journey_test.dart' as train_reduced_journey_tests;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  train_journey_table_tests.main();
  train_reduced_journey_tests.main();
}
