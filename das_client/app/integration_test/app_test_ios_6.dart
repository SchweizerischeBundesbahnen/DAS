import 'package:app/i18n/gen/app_localizations_de.dart';
import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/break_load_slip_test.dart' as break_load_slip_tests;
import 'test/journey_replacement_series_test.dart' as journey_replacement_series_test;
import 'test/journey_table_time_test.dart' as journey_table_time_tests;
import 'test/reduced_journey_table_test.dart' as reduced_journey_table_tests;

AppLocalizations l10n = AppLocalizationsDe();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  break_load_slip_tests.main();
  journey_replacement_series_test.main();
  reduced_journey_table_tests.main();
  journey_table_time_tests.main();
}
