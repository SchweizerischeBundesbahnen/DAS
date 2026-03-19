import 'package:app/i18n/i18n.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';

import 'test/journey_table_test.dart' as journey_table_tests;
import 'test/tour_system_link_test.dart' as tour_system_link_test;

late AppLocalizations l10n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS IntegrationTests').call);

  tour_system_link_test.main();
  journey_table_tests.main();
}
