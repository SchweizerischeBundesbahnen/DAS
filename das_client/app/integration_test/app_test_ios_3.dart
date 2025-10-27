import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/automatic_advancement_test.dart' as automatic_advancement_tests;
import 'test/navigation_test.dart' as navigation_tests;
import 'test/train_journey_table_advised_speeds_test.dart' as train_journey_table_adl_tests;
import 'test/train_search_test.dart' as train_search_tests;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  train_journey_table_adl_tests.main();
  navigation_tests.main();
  train_search_tests.main();
  automatic_advancement_tests.main();
}
